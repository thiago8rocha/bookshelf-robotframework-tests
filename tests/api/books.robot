*** Settings ***
Documentation    Testes de API para gerenciamento de livros

Resource    ../../base/api.resource
Resource    ../../resources/helpers/common/data.resource

Suite Setup    Run Keywords
...    Create API Session
...    Create Test User And Get Token

*** Test Cases ***

Should Reject Access Without Authentication
    [Documentation]    Valida que endpoints exigem autenticação
    [Tags]    negative    api    books    security    ID=API001
    
    ${resp}=    GET Endpoint    /api/books
    Response Status Should Be    ${resp}    401

Should List Books With Authentication
    [Documentation]    Valida listagem com token válido
    [Tags]    positive    api    books    ID=API002
    
    ${resp}=    GET Authenticated    /api/books    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    200
    Response Should Contain Key    ${resp}    books

Should Create Book With Valid Data
    [Documentation]    Valida criação com campos obrigatórios
    [Tags]    positive    api    books    ID=API003
    
    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book}    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    201
    Response Should Contain Key    ${resp}    book
    
    # Salvar ID do livro
    ${json}=    Set Variable    ${resp.json()}
    ${book}=    Set Variable    ${json['book']}
    ${book_id}=    Set Variable    ${book['id']}
    Set Suite Variable    ${CREATED_BOOK_ID}    ${book_id}

Should Create Book With Optional Fields
    [Documentation]    Valida criação com campos opcionais
    [Tags]    positive    api    books    ID=API004

    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book}    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    201

Should Not Create Book Without Title
    [Documentation]    Valida que título é obrigatório
    [Tags]    negative    api    books    validation    ID=API005
    
    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book.author}    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    400

Should Not Create Book Without Author
    [Documentation]    Valida que autor é obrigatório
    [Tags]    negative    api    books    validation    ID=API006
    
    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book.title}    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    400

Should Not Create Book With Invalid Token
    [Documentation]    Valida rejeição de token inválido
    [Tags]    negative    api    books    security    ID=API007
    
    ${book}=    Generate New Book
    
    ${resp}=    POST Authenticated    /api/books    ${book}    invalid_token_here
    Response Status Should Be    ${resp}    401

Should Get Book Statistics
    [Documentation]    Valida endpoint de estatísticas
    [Tags]    positive    api    stats    ID=API008
    
    ${resp}=    GET Authenticated    /api/stats    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    200
    Response Should Contain Key    ${resp}    stats

Should Update Book With Valid Data
    [Documentation]    Valida atualização de livro
    [Tags]    positive    api    books    ID=API009
    
    ${book}=    Generate New Book
    
    ${resp}=    PUT Authenticated    /api/books/${CREATED_BOOK_ID}    ${book}    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    200

Should Delete Book Successfully
    [Documentation]    Valida exclusão de livro
    [Tags]    positive    api    books    ID=API010
    
    ${resp}=    DELETE Authenticated    /api/books/${CREATED_BOOK_ID}    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    200

Should Not Get Deleted Book
    [Documentation]    Valida que livro deletado não existe
    [Tags]    negative    api    books    ID=API011
    
    ${resp}=    GET Authenticated    /api/books/${CREATED_BOOK_ID}    ${AUTH_TOKEN}
    Response Status Should Be    ${resp}    404