*** Settings ***
Documentation    Testes de alteração de status de livros via UI
...
...              NOTA: O frontend atual não expõe um controle de status
...              (select/dropdown com data-testid=book-status-*) na lista de livros.
...              A alteração de status existe na API mas não está implementada
...              como elemento interativo na UI.
...
...              Estes testes estão marcados como skipped (robot:skip) e serão
...              habilitados quando o frontend implementar o controle de status.

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource
Resource    ../../../resources/helpers/common/data.resource

Suite Setup    Ensure Default User Exists
Test Setup     Setup Book Status Test
Test Teardown  Teardown Book Status Test

*** Variables ***
${STATUS_USER_TOKEN}    ${EMPTY}

*** Keywords ***

Setup Book Status Test
    Setup UI Test

    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    ${token}=    Login Via API    ${credentials}[email]    ${credentials}[password]
    Set Test Variable    ${STATUS_USER_TOKEN}    ${token}
    Set Test Variable    ${STATUS_USER}    ${credentials}

    Login With Credentials    ${credentials}[email]    ${credentials}[password]

Teardown Book Status Test
    Run Keyword If    '${STATUS_USER_TOKEN}' != '${EMPTY}'
    ...    Delete All User Books Via API    ${STATUS_USER_TOKEN}
    Teardown UI Test

Get Stats Reading Count
    ${text}=    Get Text    data-testid=stats-reading
    ${matches}=    Get Regexp Matches    ${text}    (\\d+)
    ${count}=    Convert To Integer    ${matches}[0]
    RETURN    ${count}

*** Test Cases ***

User Can Change Book Status To Reading
    [Documentation]    Usuário marca um livro como "Lendo" via UI
    ...                SKIP: frontend não implementa select de status na lista de livros
    [Tags]    positive    books    ui    status    robot:skip    ID=BSTAT001

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    ${reading_before}=    Get Stats Reading Count

    Change Book Status    ${book}[title]    reading
    Book Status Should Be    ${book}[title]    reading

    ${reading_after}=    Get Stats Reading Count
    Should Be Equal As Integers    ${reading_after}    ${reading_before + 1}

User Can Change Book Status To Read
    [Documentation]    Usuário marca um livro como "Lido"
    ...                SKIP: frontend não implementa select de status na lista de livros
    [Tags]    positive    books    ui    status    robot:skip    ID=BSTAT002

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Change Book Status    ${book}[title]    read
    Book Status Should Be    ${book}[title]    read

User Can Change Book Status Back To To Read
    [Documentation]    Usuário reverte um livro de "Lendo" para "Quero Ler"
    ...                SKIP: frontend não implementa select de status na lista de livros
    [Tags]    positive    books    ui    status    robot:skip    ID=BSTAT003

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Change Book Status    ${book}[title]    reading
    Book Status Should Be    ${book}[title]    reading

    Change Book Status    ${book}[title]    to_read
    Book Status Should Be    ${book}[title]    to_read

Reading Stats Increment When Status Changes To Reading
    [Documentation]    O contador "Lendo" no dashboard incrementa quando status muda para reading
    ...                SKIP: frontend não implementa select de status na lista de livros
    [Tags]    positive    books    ui    status    statistics    robot:skip    ID=BSTAT004

    ${book1}=    Generate Book With Required Fields Only
    ${book2}=    Generate Book With Required Fields Only
    User Creates Book    ${book1}
    User Creates Book    ${book2}

    ${antes}=    Get Stats Reading Count
    Should Be Equal As Integers    ${antes}    0

    Change Book Status    ${book1}[title]    reading
    ${apos_um}=    Get Stats Reading Count
    Should Be Equal As Integers    ${apos_um}    1

    Change Book Status    ${book2}[title]    reading
    ${apos_dois}=    Get Stats Reading Count
    Should Be Equal As Integers    ${apos_dois}    2

Reading Stats Decrement When Status Leaves Reading
    [Documentation]    O contador "Lendo" diminui quando o status sai de "reading"
    ...                SKIP: frontend não implementa select de status na lista de livros
    [Tags]    positive    books    ui    status    statistics    robot:skip    ID=BSTAT005

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Change Book Status    ${book}[title]    reading
    ${lendo}=    Get Stats Reading Count
    Should Be Equal As Integers    ${lendo}    1

    Change Book Status    ${book}[title]    read
    ${pos_read}=    Get Stats Reading Count
    Should Be Equal As Integers    ${pos_read}    0

New Book Default Status Is To Read
    [Documentation]    Livro recém-criado tem status padrão "to_read" (Quero Ler)
    ...                SKIP: frontend não implementa select de status na lista de livros
    [Tags]    positive    books    ui    status    robot:skip    ID=BSTAT006

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Book Status Should Be    ${book}[title]    to_read

Status Change Persists After Page Reload
    [Documentation]    Alteração de status persiste após recarregar a página
    ...                SKIP: frontend não implementa select de status na lista de livros
    [Tags]    positive    books    ui    status    persistence    robot:skip    ID=BSTAT007

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Change Book Status    ${book}[title]    reading

    Reload
    Wait For Load State    networkidle
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=15s

    Book Status Should Be    ${book}[title]    reading