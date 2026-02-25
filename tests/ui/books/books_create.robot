*** Settings ***
Documentation    Testes de criação de livros e validação de listagem

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource
Resource    ../../../resources/helpers/common/data.resource

Test Setup    Setup Book Creation Test
Test Teardown    Teardown Book Creation Test

*** Variables ***
${TEST_USER_TOKEN}    ${EMPTY}

*** Keywords ***

Setup Book Creation Test
    [Documentation]    Setup para cada teste - cria browser e usuário único
    Setup UI Test
    
    ${user}    ${books}=    Create User With Books    book_count=2
    
    Set Test Variable    ${TEST_USER}        ${user}
    Set Test Variable    ${TEST_USER_BOOKS}  ${books}
    
    ${token}=    Login Via API    ${user}[email]    ${user}[password]
    Set Test Variable    ${TEST_USER_TOKEN}    ${token}
    
    Login With Credentials    ${user}[email]    ${user}[password]

Teardown Book Creation Test
    [Documentation]    Teardown - limpa livros e fecha browser
    
    Run Keyword If    '${TEST_USER_TOKEN}' != '${EMPTY}'
    ...    Delete All User Books Via API    ${TEST_USER_TOKEN}
    
    Teardown UI Test

Setup Fresh User Test
    [Documentation]    Setup específico para testes de usuário novo
    Setup UI Test

Get Book Count From UI
    [Documentation]    Obtém quantidade de livros das estatísticas
    ${stats_text}=    Get Text    data-testid=stats-total
    ${matches}=    Get Regexp Matches    ${stats_text}    (\\d+)
    ${count}=    Convert To Integer    ${matches}[0]
    RETURN    ${count}

*** Test Cases ***

Old User Can Create Book With Required Fields
    [Documentation]    Valida criação de um livro com campos obrigatórios preenchidos
    [Tags]    positive    books    ui    smoke    ID=BOOKS001
    
    ${initial_count}=    Get Book Count From UI
    
    ${book}=    Generate New Book
    User Creates Book    ${book}
    
    Book Should Exist In List    ${book}[title]
    
    ${final_count}=    Get Book Count From UI
    Should Be Equal As Integers    ${final_count}    ${initial_count + 1}

Old User Can Create Book With All Fields
    [Documentation]    Valida criação de um livro com todos os campos preenchidos
    [Tags]    positive    books    ui    regression    ID=BOOKS002
    
    ${initial_count}=    Get Book Count From UI
    
    ${book}=    Generate New Book
    User Creates Complete Book    ${book}
    
    Book Should Exist In List    ${book}[title]
    ${final_count}=    Get Book Count From UI
    Should Be Equal As Integers    ${final_count}    ${initial_count + 1}

Old User Can See Book Count In Statistics After Creating
    [Documentation]    Valida que estatísticas incrementam após criação
    [Tags]    positive    books    ui    statistics    ID=BOOKS003
    
    ${initial_text}=    Get Text    data-testid=stats-total
    ${matches}=    Get Regexp Matches    ${initial_text}    (\\d+)
    ${initial_count}=    Set Variable    ${matches}[0]
    
    ${book}=    Generate New Book
    User Creates Book    ${book}
    
    ${new_text}=    Get Text    data-testid=stats-total
    ${matches}=    Get Regexp Matches    ${new_text}    (\\d+)
    ${new_count}=    Set Variable    ${matches}[0]
    
    ${initial_int}=    Convert To Integer    ${initial_count}
    ${new_int}=    Convert To Integer    ${new_count}
    Should Be True    ${new_int} > ${initial_int}

Old User Can View Book List After Creating Multiple Books
    [Documentation]    Valida que múltiplos livros criados aparecem na lista
    [Tags]    positive    books    ui    regression    ID=BOOKS004
    
    ${book1}=    Generate New Book
    ${book2}=    Generate New Book
    
    User Creates Book    ${book1}
    User Creates Book    ${book2}
    
    Book Should Exist In List    ${book1}[title]
    Book Should Exist In List    ${book2}[title]

New User Can View Empty Book List
    [Documentation]    Valida a mensagem de biblioteca vazia para um usuário novo
    [Tags]    positive    books    ui    smoke    fresh-user    ID=BOOKS005
    
    [Setup]    Setup Fresh User Test
    ${credentials}=    Create Fresh User And Login
    
    ${page_content}=    Get Text    body
    Should Contain Any    ${page_content}
    ...    Nenhum livro cadastrado
    ...    Nenhum livro ainda
    ...    biblioteca vazia
    ...    Adicione seu primeiro livro
    
    ${stats_text}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_text}    0

New User Statistics Start At Zero
    [Documentation]    Valida que estatísticas de usuário novo começam em zero
    [Tags]    positive    books    ui    statistics    fresh-user    ID=BOOKS006
    
    [Setup]    Setup Fresh User Test
    ${credentials}=    Create Fresh User And Login
    
    ${total_text}=     Get Text    data-testid=stats-total
    ${reading_text}=   Get Text    data-testid=stats-reading
    
    Should Contain    ${total_text}      0
    Should Contain    ${reading_text}    0

New User Can Create First Book With Required Fields
    [Documentation]    Valida criação do primeiro livro de um usuário novo
    [Tags]    positive    books    ui    fresh-user    ID=BOOKS007
    
    [Setup]    Setup Fresh User Test
    ${credentials}=    Create Fresh User And Login
    
    ${stats_before}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_before}    0
    
    ${book}=    Generate New Book
    User Creates Book    ${book}
    Book Should Exist In List    ${book}[title]
    
    ${stats_after}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_after}    1

New User Can Create First Book With All Fields
    [Documentation]    Valida criação completa do primeiro livro de um usuário novo
    [Tags]    positive    books    ui    fresh-user    ID=BOOKS008
    
    [Setup]    Setup Fresh User Test
    ${credentials}=    Create Fresh User And Login
    
    ${stats_before}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_before}    0
    
    ${book}=    Generate New Book
    User Creates Complete Book    ${book}
    Book Should Exist In List    ${book}[title]
    
    ${stats_after}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_after}    1

User Cannot Create Book Without Title
    [Documentation]    Valida que título é obrigatório
    [Tags]    negative    books    ui    validation    ID=BOOKS009
    
    Click Add Book Button
    Fill Text    id=author    Some Author
    
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    id=title    required
    Should Be True    ${has_required}

User Cannot Create Book Without Author
    [Documentation]    Valida que autor é obrigatório
    [Tags]    negative    books    ui    validation    ID=BOOKS010
    
    Click Add Book Button
    Fill Text    id=title    Some Title
    
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    id=author    required
    Should Be True    ${has_required}

User Can Cancel Book Creation
    [Documentation]    Valida cancelar criação
    [Tags]    negative    books    ui    ID=BOOKS011
    
    Click Add Book Button
    Fill Text    id=title    Test Title To Cancel
    Click Cancel Button
    
    ${form_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    id=title    visible    timeout=2s
    Should Not Be True    ${form_visible}