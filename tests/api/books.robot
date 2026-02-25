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

*** Test Cases ***

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