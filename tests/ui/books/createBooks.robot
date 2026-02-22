*** Settings ***
Documentation    Testes de criação de livros e validação de listagem

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource

Test Setup    Run Keywords
...    Setup UI Test
...    Login As Valid User

Test Teardown    Teardown UI Test

*** Test Cases ***

Old User Can Create Book With Required Fields
    [Documentation]    Valida criação de um livro com campos obrigatórios preenchidos
    [Tags]    positive    books    ui    smoke    ID=BOOKS001
    
    ${book}=    Generate New Book
    User Creates Book    ${book}  
    Book Should Exist In List    ${book.title}

Old User Can Create Book With All Fields
    [Documentation]    Valida criação de um livro com todos os campos preenchidos
    [Tags]    positive    books    ui    regression    ID=BOOKS002
    
    ${book}=    Generate New Book
    User Creates Complete Book    ${book}
    Book Should Exist In List    ${book.title}

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

Old User Can View Book List After Creating Books
    [Documentation]    Valida que múltiplos livros criados aparecem na lista
    [Tags]    positive    books    ui    regression    ID=BOOKS004
    
    ${book1}=    Generate New Book
    ${book2}=    Generate New Book
    
    User Creates Book    ${book1}
    User Creates Book    ${book2}
    
    Book Should Exist In List    ${book1.title}
    Book Should Exist In List    ${book2.title}

New User Can View Empty Book List
    [Documentation]    Valida a mensagem de biblioteca vazia para um usuário novo
    [Tags]    positive    books    ui    smoke    fresh-user    ID=BOOKS005
    
    [Setup]    Setup UI Test
    Register And Login Fresh User
    
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
    
    [Setup]    Setup UI Test
    Register And Login Fresh User
    
    ${total_text}=    Get Text    data-testid=stats-total
    ${reading_text}=    Get Text    data-testid=stats-reading
    
    Should Contain    ${total_text}    0
    Should Contain    ${reading_text}    0

New User Can Create First Book With Required Fields
    [Documentation]    Valida criação do primeiro livro de um usuário novo
    [Tags]    positive    books    ui    fresh-user    ID=BOOKS007
    
    [Setup]    Setup UI Test
    Register And Login Fresh User
    
    ${stats_before}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_before}    0
    
    ${book}=    Generate New Book
    User Creates Book    ${book}
    Book Should Exist In List    ${book.title}
    
    ${stats_after}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_after}    1

New User Can Create First Book With All Fields
    [Documentation]    Valida criação completa do primeiro livro de um usuário novo
    [Tags]    positive    books    ui    fresh-user    ID=BOOKS008
    
    [Setup]    Setup UI Test
    Register And Login Fresh User
    
    ${stats_before}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_before}    0
    
    ${book}=    Generate New Book
    User Creates Complete Book    ${book}
    Book Should Exist In List    ${book.title}
    
    ${stats_after}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_after}    1

User Cannot Create Book Without Title
    [Documentation]    Valida que título é obrigatório
    [Tags]    negative    books    ui    validation    ID=BOOKS009
    
    Click Add Book Button
    Fill Text    id=author    Some Author
    
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    id=title    required
    Should Be True    ${has_required}    msg=Campo título deve ser obrigatório

User Cannot Create Book Without Author
    [Documentation]    Valida que autor é obrigatório
    [Tags]    negative    books    ui    validation    ID=BOOKS010
    
    Click Add Book Button
    Fill Text    id=title    Some Title
    
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    id=author    required
    Should Be True    ${has_required}    msg=Campo autor deve ser obrigatório

User Can Cancel Book Creation
    [Documentation]    Valida cancelar criação
    [Tags]    negative    books    ui    ID=BOOKS011
    
    Click Add Book Button
    Fill Text    id=title    Test Title
    Click Cancel Button