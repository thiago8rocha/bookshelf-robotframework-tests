*** Settings ***
Documentation    Testes de API para gerenciamento de livros

Resource    ../../base/api.resource
Resource    ../../resources/helpers/common/data.resource

Suite Setup    Setup Books API Suite
Suite Teardown    Teardown Books API Suite

*** Variables ***
${SUITE_USER_TOKEN}     ${EMPTY}
${SUITE_USER_EMAIL}     ${EMPTY}
@{CREATED_BOOK_IDS}     

*** Keywords ***

Setup Books API Suite
    [Documentation]    Cria sessão API e usuário único para a suite
    Create API Session
    
    ${credentials}=    Generate Unique User Credentials
    Set Suite Variable    ${SUITE_USER_EMAIL}    ${credentials}[email]
    
    ${user_response}=    Create User Via API    ${credentials}
    ${token}=            Login Via API    ${credentials}[email]    ${credentials}[password]
    
    Set Suite Variable    ${SUITE_USER_TOKEN}    ${token}

Teardown Books API Suite
    [Documentation]    Limpa todos os livros criados durante a suite
    Delete All User Books Via API    ${SUITE_USER_TOKEN}

Save Book ID For Cleanup
    [Documentation]    Salva ID do livro para cleanup no teardown
    [Arguments]    ${book_id}
    Append To List    ${CREATED_BOOK_IDS}    ${book_id}

Create Book For Test
    [Documentation]    Cria livro e retorna o ID — atalho para testes que precisam de um livro existente
    [Arguments]    ${token}=${SUITE_USER_TOKEN}
    ${book}=    Generate Book With Required Fields Only
    ${resp}=    POST Authenticated    /api/books    ${book}    ${token}
    ${book_id}=    Set Variable    ${resp.json()}[book][id]
    Save Book ID For Cleanup    ${book_id}
    RETURN    ${book_id}

*** Test Cases ***

# ─── GET /api/books ───────────────────────────────────────────────────────────

Should Reject Access Without Authentication
    [Documentation]    Valida que endpoints exigem autenticação
    [Tags]    negative    api    books    security    ID=API001
    
    ${resp}=    GET Endpoint    /api/books
    Response Status Should Be    ${resp}    401
    
    Response Should Contain Key    ${resp}    error

Should List Books With Authentication
    [Documentation]    Valida listagem com token válido
    [Tags]    positive    api    books    ID=API002
    
    ${resp}=    GET Authenticated    /api/books    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200
    Response Should Contain Key    ${resp}    books
    
    ${json}=    Set Variable    ${resp.json()}
    ${books}=    Set Variable    ${json}[books]
    ${is_list}=    Evaluate    isinstance($books, list)
    Should Be True    ${is_list}

List Response Should Contain Pagination
    [Documentation]    GET /api/books sempre retorna objeto 'pagination' com page/limit/total/totalPages
    ...                Backend: BooksService.list retorna { books, pagination: { page, limit, total, totalPages } }
    [Tags]    positive    api    books    contract    ID=API016

    ${resp}=    GET Authenticated    /api/books    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200

    ${json}=    Set Variable    ${resp.json()}
    Dictionary Should Contain Key    ${json}    pagination
    ${pag}=    Set Variable    ${json}[pagination]

    Dictionary Should Contain Key    ${pag}    page
    Dictionary Should Contain Key    ${pag}    limit
    Dictionary Should Contain Key    ${pag}    total
    Dictionary Should Contain Key    ${pag}    totalPages

    ${is_int}=    Evaluate    isinstance($pag['total'], int)
    Should Be True    ${is_int}
    Should Be True    ${pag}[total] >= 0

Should Filter Books By Status Reading
    [Documentation]    Filtro ?status=reading retorna apenas livros com status reading
    [Tags]    positive    api    books    filter    ID=API017

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    status=reading
    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}

    ${resp}=    GET Authenticated    /api/books?status=reading    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200

    ${books}=    Set Variable    ${resp.json()}[books]
    FOR    ${book}    IN    @{books}
        Should Be Equal    ${book}[status]    reading
    END

Should Filter Books By Status Read
    [Documentation]    Filtro ?status=read retorna apenas livros com status read
    [Tags]    positive    api    books    filter    ID=API018

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    status=read
    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}

    ${resp}=    GET Authenticated    /api/books?status=read    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200

    ${books}=    Set Variable    ${resp.json()}[books]
    FOR    ${book}    IN    @{books}
        Should Be Equal    ${book}[status]    read
    END

# ─── GET /api/books/:id ───────────────────────────────────────────────────────

Should Get Book By ID
    [Documentation]    GET /api/books/:id retorna o livro com schema completo
    ...                Inclui id, title, author, status — campos obrigatórios do model
    [Tags]    positive    api    books    ID=API019

    ${book}=    Generate Book With Required Fields Only
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    ${book_id}=    Set Variable    ${create_resp.json()}[book][id]
    Save Book ID For Cleanup    ${book_id}

    ${resp}=    GET Authenticated    /api/books/${book_id}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200

    ${json}=    Set Variable    ${resp.json()}
    Dictionary Should Contain Key    ${json}    book
    ${item}=    Set Variable    ${json}[book]

    Dictionary Should Contain Key    ${item}    id
    Dictionary Should Contain Key    ${item}    title
    Dictionary Should Contain Key    ${item}    author
    Dictionary Should Contain Key    ${item}    status
    Should Be Equal    ${item}[id]        ${book_id}
    Should Be Equal    ${item}[title]     ${book}[title]
    Should Be Equal    ${item}[author]    ${book}[author]
    Should Be Equal    ${item}[status]    to_read

Should Return 404 For Nonexistent Book ID
    [Documentation]    GET /api/books/:id com UUID inexistente retorna 404
    [Tags]    negative    api    books    ID=API020

    ${resp}=    GET Authenticated    /api/books/00000000-0000-0000-0000-000000000000    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    404
    Response Should Contain Key    ${resp}    error

# ─── POST /api/books ──────────────────────────────────────────────────────────

Should Create Book With Valid Data
    [Documentation]    Valida criação com campos obrigatórios
    [Tags]    positive    api    books    ID=API003
    
    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    201
    Response Should Contain Key    ${resp}    book
    
    ${json}=    Set Variable    ${resp.json()}
    ${created_book}=    Set Variable    ${json}[book]
    Dictionary Should Contain Key    ${created_book}    id
    
    Should Be Equal    ${created_book}[title]     ${book}[title]
    Should Be Equal    ${created_book}[author]    ${book}[author]
    
    Save Book ID For Cleanup    ${created_book}[id]

Should Create Book With Optional Fields
    [Documentation]    Valida criação com campos opcionais
    [Tags]    positive    api    books    ID=API004

    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    201
    
    ${json}=    Set Variable    ${resp.json()}
    ${created_book}=    Set Variable    ${json}[book]
    
    Should Be Equal    ${created_book}[title]          ${book}[title]
    Should Be Equal    ${created_book}[author]         ${book}[author]
    Should Be Equal    ${created_book}[isbn]           ${book}[isbn]
    Should Be Equal    ${created_book}[publisher]      ${book}[publisher]
    Should Be Equal As Integers    ${created_book}[publishedYear]    ${book}[publishedYear]
    Should Be Equal As Integers    ${created_book}[pages]           ${book}[pages]
    
    Save Book ID For Cleanup    ${created_book}[id]

Created Book Should Have Default Status To Read
    [Documentation]    Livro criado deve ter status 'to_read' por padrão
    ...                Backend: status: BookStatus.TO_READ na criação
    [Tags]    positive    api    books    contract    ID=API021

    ${book}=    Generate Book With Required Fields Only
    ${resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    201

    ${created}=    Set Variable    ${resp.json()}[book]
    Should Be Equal    ${created}[status]    to_read
    Save Book ID For Cleanup    ${created}[id]

Should Not Create Book Without Title
    [Documentation]    Valida que título é obrigatório
    [Tags]    negative    api    books    validation    ID=API005
    
    ${book}=    Generate New Book
    ${body}=    Create Dictionary    author=${book}[author]
    
    ${resp}=    POST Authenticated    /api/books    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    
    ${json}=    Set Variable    ${resp.json()}
    Response Should Contain Key    ${resp}    error

Should Not Create Book Without Author
    [Documentation]    Valida que autor é obrigatório
    [Tags]    negative    api    books    validation    ID=API006
    
    ${book}=    Generate New Book
    ${body}=    Create Dictionary    title=${book}[title]
    
    ${resp}=    POST Authenticated    /api/books    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    
    ${json}=    Set Variable    ${resp.json()}
    Response Should Contain Key    ${resp}    error

Should Not Create Book With Invalid Token
    [Documentation]    Valida rejeição de token inválido
    [Tags]    negative    api    books    security    ID=API007
    
    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book}    invalid_token_here
    Response Status Should Be    ${resp}    401

Should Not Create Book With Future Published Year
    [Documentation]    Ano de publicação no futuro deve ser rejeitado com 400
    ...                Backend: if (publishedYear > new Date().getFullYear()) throw Error
    [Tags]    negative    api    books    validation    ID=API022

    ${next_year}=    Evaluate    __import__('datetime').datetime.now().year + 1
    ${book}=    Generate Book With Required Fields Only
    Set To Dictionary    ${book}    publishedYear    ${next_year}

    ${resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    Response Should Contain Key    ${resp}    error

Should Not Create Book With Rating Out Of Range
    [Documentation]    Rating fora do range 1–5 deve ser rejeitado com 400
    ...                Backend: if (rating < 1 || rating > 5) throw Error
    [Tags]    negative    api    books    validation    ID=API023

    ${book}=    Generate Book With Required Fields Only
    Set To Dictionary    ${book}    rating    ${6}

    ${resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    Response Should Contain Key    ${resp}    error

Should Not Create Book With Duplicate ISBN
    [Documentation]    ISBN já cadastrado deve retornar 409
    ...                Backend: findOne({ where: { isbn } }) → 409 se existir
    [Tags]    negative    api    books    validation    ID=API024

    ${book1}=    Generate New Book
    ${resp1}=    POST Authenticated    /api/books    ${book1}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp1}    201
    Save Book ID For Cleanup    ${resp1.json()}[book][id]

    ${book2}=    Generate Book With Required Fields Only
    Set To Dictionary    ${book2}    isbn    ${book1}[isbn]

    ${resp2}=    POST Authenticated    /api/books    ${book2}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp2}    409
    Response Should Contain Key    ${resp2}    error

# ─── PUT /api/books/:id ───────────────────────────────────────────────────────

Should Update Book With Valid Data
    [Documentation]    Valida atualização de livro
    [Tags]    positive    api    books    ID=API009
    
    ${book}=    Generate New Book
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    ${created}=    Set Variable    ${create_resp.json()}[book]
    ${book_id}=    Set Variable    ${created}[id]
    Save Book ID For Cleanup    ${book_id}
    
    ${update_data}=    Generate New Book
    
    ${resp}=    PUT Authenticated    /api/books/${book_id}    ${update_data}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200
    
    ${json}=    Set Variable    ${resp.json()}
    ${updated}=    Set Variable    ${json}[book]
    Should Be Equal    ${updated}[title]    ${update_data}[title]
    Should Be Equal    ${updated}[author]   ${update_data}[author]

Should Return 404 When Updating Nonexistent Book
    [Documentation]    PUT em UUID inexistente deve retornar 404
    [Tags]    negative    api    books    ID=API025

    ${update_data}=    Generate Book With Required Fields Only
    ${resp}=    PUT Authenticated    /api/books/00000000-0000-0000-0000-000000000000    ${update_data}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    404
    Response Should Contain Key    ${resp}    error

Should Not Update Book With Rating Out Of Range
    [Documentation]    Rating fora do range 1–5 no update deve retornar 400
    [Tags]    negative    api    books    validation    ID=API026

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    rating=${0}
    ${resp}=    PUT Authenticated    /api/books/${book_id}    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    Response Should Contain Key    ${resp}    error

Should Not Update Book With Future Published Year
    [Documentation]    Ano de publicação no futuro no update deve retornar 400
    [Tags]    negative    api    books    validation    ID=API027

    ${book_id}=    Create Book For Test
    ${next_year}=    Evaluate    __import__('datetime').datetime.now().year + 1
    ${body}=    Create Dictionary    publishedYear=${next_year}
    ${resp}=    PUT Authenticated    /api/books/${book_id}    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    Response Should Contain Key    ${resp}    error

Should Not Update Book With Duplicate ISBN
    [Documentation]    ISBN já usado em outro livro no update deve retornar 409
    [Tags]    negative    api    books    validation    ID=API028

    ${book1}=    Generate New Book
    ${resp1}=    POST Authenticated    /api/books    ${book1}    ${SUITE_USER_TOKEN}
    Save Book ID For Cleanup    ${resp1.json()}[book][id]
    ${isbn_taken}=    Set Variable    ${book1}[isbn]

    ${book_id2}=    Create Book For Test
    ${body}=    Create Dictionary    isbn=${isbn_taken}
    ${resp}=    PUT Authenticated    /api/books/${book_id2}    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    409
    Response Should Contain Key    ${resp}    error

# ─── DELETE /api/books/:id ────────────────────────────────────────────────────

Should Delete Book Successfully
    [Documentation]    Valida exclusão de livro
    [Tags]    positive    api    books    ID=API010
    
    ${book}=    Generate New Book
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    ${book_id}=    Set Variable    ${create_resp.json()}[book][id]
    
    ${resp}=    DELETE Authenticated    /api/books/${book_id}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200
    
    ${get_resp}=    GET Authenticated    /api/books/${book_id}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${get_resp}    404

Should Not Get Deleted Book
    [Documentation]    Valida que livro deletado não existe
    [Tags]    negative    api    books    ID=API011
    
    ${book}=    Generate New Book
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
    ${book_id}=    Set Variable    ${create_resp.json()}[book][id]
    
    DELETE Authenticated    /api/books/${book_id}    ${SUITE_USER_TOKEN}
    
    ${resp}=    GET Authenticated    /api/books/${book_id}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    404

Should Return 404 When Deleting Nonexistent Book
    [Documentation]    DELETE em UUID inexistente deve retornar 404
    [Tags]    negative    api    books    ID=API029

    ${resp}=    DELETE Authenticated    /api/books/00000000-0000-0000-0000-000000000000    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    404
    Response Should Contain Key    ${resp}    error

# ─── Authorization (cross-user) ───────────────────────────────────────────────

User Cannot Access Another Users Book
    [Documentation]    Valida que usuário não pode acessar livro de outro
    [Tags]    negative    api    books    security    authorization    ID=API012
    
    ${user2}=    Generate Unique User Credentials
    Create User Via API    ${user2}
    ${user2_token}=    Login Via API    ${user2}[email]    ${user2}[password]
    
    ${book}=    Generate New Book
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${user2_token}
    ${book_id}=    Set Variable    ${create_resp.json()}[book][id]
    
    ${resp}=    GET Authenticated    /api/books/${book_id}    ${SUITE_USER_TOKEN}
    
    ${status}=    Set Variable    ${resp.status_code}
    ${is_denied}=    Evaluate    ${status} in [403, 404]
    Should Be True    ${is_denied}

User Cannot Update Another Users Book
    [Documentation]    Valida que usuário não pode atualizar livro de outro
    [Tags]    negative    api    books    security    authorization    ID=API013
    
    ${user2}=    Generate Unique User Credentials
    Create User Via API    ${user2}
    ${user2_token}=    Login Via API    ${user2}[email]    ${user2}[password]
    
    ${book}=    Generate New Book
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${user2_token}
    ${book_id}=    Set Variable    ${create_resp.json()}[book][id]
    
    ${update_data}=    Generate New Book
    ${resp}=    PUT Authenticated    /api/books/${book_id}    ${update_data}    ${SUITE_USER_TOKEN}
    
    ${status}=    Set Variable    ${resp.status_code}
    ${is_denied}=    Evaluate    ${status} in [403, 404]
    Should Be True    ${is_denied}

User Cannot Delete Another Users Book
    [Documentation]    Valida que usuário não pode deletar livro de outro
    [Tags]    negative    api    books    security    authorization    ID=API014
    
    ${user2}=    Generate Unique User Credentials
    Create User Via API    ${user2}
    ${user2_token}=    Login Via API    ${user2}[email]    ${user2}[password]
    
    ${book}=    Generate New Book
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${user2_token}
    ${book_id}=    Set Variable    ${create_resp.json()}[book][id]
    
    ${resp}=    DELETE Authenticated    /api/books/${book_id}    ${SUITE_USER_TOKEN}
    
    ${status}=    Set Variable    ${resp.status_code}
    ${is_denied}=    Evaluate    ${status} in [403, 404]
    Should Be True    ${is_denied}

# ─── PATCH /api/books/:id/status ─────────────────────────────────────────────

Should Update Book Status To Reading
    [Documentation]    PATCH /api/books/:id/status muda status para 'reading'
    ...                Backend também preenche startedAt automaticamente
    [Tags]    positive    api    books    status    ID=API030

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    status=reading
    ${resp}=    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200

    ${book}=    Set Variable    ${resp.json()}[book]
    Should Be Equal    ${book}[status]    reading
    Dictionary Should Contain Key    ${book}    startedAt

Should Update Book Status To Read
    [Documentation]    PATCH /api/books/:id/status muda status para 'read'
    ...                Backend também preenche finishedAt automaticamente
    [Tags]    positive    api    books    status    ID=API031

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    status=read
    ${resp}=    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200

    ${book}=    Set Variable    ${resp.json()}[book]
    Should Be Equal    ${book}[status]    read
    Dictionary Should Contain Key    ${book}    finishedAt

Should Update Book Status Back To To Read
    [Documentation]    PATCH /api/books/:id/status pode voltar para 'to_read'
    [Tags]    positive    api    books    status    ID=API032

    ${book_id}=    Create Book For Test
    ${body_reading}=    Create Dictionary    status=reading
    PATCH Authenticated    /api/books/${book_id}/status    ${body_reading}    ${SUITE_USER_TOKEN}

    ${body_to_read}=    Create Dictionary    status=to_read
    ${resp}=    PATCH Authenticated    /api/books/${book_id}/status    ${body_to_read}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200
    Should Be Equal    ${resp.json()}[book][status]    to_read

Should Not Update Status With Invalid Value
    [Documentation]    Status inválido (ex: 'lendo') deve retornar 400
    ...                Backend: validStatuses = ['to_read', 'reading', 'read']
    [Tags]    negative    api    books    status    validation    ID=API033

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    status=lendo
    ${resp}=    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    Response Should Contain Key    ${resp}    error

Should Not Update Status Without Status Field
    [Documentation]    Body sem campo 'status' deve retornar 400
    [Tags]    negative    api    books    status    validation    ID=API034

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    outro_campo=valor
    ${resp}=    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400
    Response Should Contain Key    ${resp}    error

Should Not Update Status Of Another Users Book
    [Documentation]    PATCH status em livro de outro usuário deve retornar 404
    [Tags]    negative    api    books    status    authorization    ID=API035

    ${user2}=    Generate Unique User Credentials
    Create User Via API    ${user2}
    ${user2_token}=    Login Via API    ${user2}[email]    ${user2}[password]

    ${book}=    Generate Book With Required Fields Only
    ${create_resp}=    POST Authenticated    /api/books    ${book}    ${user2_token}
    ${book_id}=    Set Variable    ${create_resp.json()}[book][id]

    ${body}=    Create Dictionary    status=reading
    ${resp}=    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}

    ${status}=    Set Variable    ${resp.status_code}
    ${is_denied}=    Evaluate    ${status} in [403, 404]
    Should Be True    ${is_denied}

Should Not Update Status Without Token
    [Documentation]    PATCH status sem token deve retornar 401
    [Tags]    negative    api    books    status    security    ID=API036

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    status=reading

    Create Session    no_auth_session    ${API_URL}
    ${resp}=    PATCH On Session    no_auth_session
    ...         /api/books/${book_id}/status
    ...         json=${body}
    ...         expected_status=any

    Response Status Should Be    ${resp}    401

# ─── GET /api/stats ───────────────────────────────────────────────────────────

Should Get Book Statistics
    [Documentation]    Valida endpoint de estatísticas
    [Tags]    positive    api    stats    ID=API008
    
    ${resp}=    GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200
    Response Should Contain Key    ${resp}    stats
    
    ${json}=    Set Variable    ${resp.json()}
    ${stats}=    Set Variable    ${json}[stats]
    Dictionary Should Contain Key    ${stats}    total
    
    ${total}=    Set Variable    ${stats}[total]
    ${is_number}=    Evaluate    isinstance($total, int)
    Should Be True    ${is_number}
    Should Be True    ${total} >= 0

Stats Should Contain Full Schema
    [Documentation]    GET /api/stats retorna schema completo: byStatus, averageRating, totalPages
    ...                Backend: StatsService.overview retorna todos esses campos sempre
    [Tags]    positive    api    stats    contract    ID=API037

    ${resp}=    GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200

    ${stats}=    Set Variable    ${resp.json()}[stats]

    # byStatus com os três sub-campos
    Dictionary Should Contain Key    ${stats}    byStatus
    ${by_status}=    Set Variable    ${stats}[byStatus]
    Dictionary Should Contain Key    ${by_status}    toRead
    Dictionary Should Contain Key    ${by_status}    reading
    Dictionary Should Contain Key    ${by_status}    read

    # averageRating e totalPages
    Dictionary Should Contain Key    ${stats}    averageRating
    Dictionary Should Contain Key    ${stats}    totalPages

    # Todos são números >= 0
    Should Be True    ${by_status}[toRead] >= 0
    Should Be True    ${by_status}[reading] >= 0
    Should Be True    ${by_status}[read] >= 0
    Should Be True    ${stats}[averageRating] >= 0
    Should Be True    ${stats}[totalPages] >= 0

Statistics Should Reflect Book Count
    [Documentation]    Valida que estatísticas refletem contagem real
    [Tags]    positive    api    stats    integration    ID=API015
    
    ${initial_resp}=    GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    ${initial_total}=    Set Variable    ${initial_resp.json()}[stats][total]
    
    FOR    ${i}    IN RANGE    3
        ${book}=    Generate New Book
        ${resp}=    POST Authenticated    /api/books    ${book}    ${SUITE_USER_TOKEN}
        ${book_id}=    Set Variable    ${resp.json()}[book][id]
        Save Book ID For Cleanup    ${book_id}
    END
    
    ${final_resp}=    GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    ${final_total}=    Set Variable    ${final_resp.json()}[stats][total]
    
    ${expected}=    Evaluate    ${initial_total} + 3
    Should Be Equal As Integers    ${final_total}    ${expected}

Stats ByStatus Should Reflect Status Changes
    [Documentation]    Contadores byStatus devem refletir mudanças de status nos livros
    [Tags]    positive    api    stats    integration    ID=API038

    ${initial_resp}=    GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    ${initial_reading}=    Set Variable    ${initial_resp.json()}[stats][byStatus][reading]

    ${book_id}=    Create Book For Test
    ${body}=    Create Dictionary    status=reading
    PATCH Authenticated    /api/books/${book_id}/status    ${body}    ${SUITE_USER_TOKEN}

    ${final_resp}=    GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    ${final_reading}=    Set Variable    ${final_resp.json()}[stats][byStatus][reading]

    ${expected}=    Evaluate    ${initial_reading} + 1
    Should Be Equal As Integers    ${final_reading}    ${expected}
