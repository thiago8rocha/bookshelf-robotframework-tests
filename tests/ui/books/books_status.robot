*** Settings ***
Documentation    Testes de alteração de status de livros via UI
...
...              Valida que o usuário pode marcar um livro como
...              "Lendo", "Lido" ou voltar para "Quero Ler",
...              e que os contadores do dashboard refletem as mudanças.

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
    ${matches}=    Get Regexp Matches    ${text}    (\d+)
    ${count}=    Convert To Integer    ${matches}[0]
    RETURN    ${count}

*** Test Cases ***

User Can Change Book Status To Reading
    [Documentation]    Usuário marca um livro como "Lendo" via UI
    ...                O status é atualizado e o contador "Lendo" incrementa
    [Tags]    positive    books    ui    status    ID=BSTAT001

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    ${reading_before}=    Get Stats Reading Count

    Change Book Status    ${book}[title]    reading
    Book Status Should Be    ${book}[title]    reading

    ${reading_after}=    Get Stats Reading Count
    Should Be Equal As Integers    ${reading_after}    ${reading_before + 1}

User Can Change Book Status To Read
    [Documentation]    Usuário marca um livro como "Lido"
    [Tags]    positive    books    ui    status    ID=BSTAT002

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Change Book Status    ${book}[title]    read
    Book Status Should Be    ${book}[title]    read

User Can Change Book Status Back To To Read
    [Documentation]    Usuário reverte um livro de "Lendo" para "Quero Ler"
    [Tags]    positive    books    ui    status    ID=BSTAT003

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Change Book Status    ${book}[title]    reading
    Book Status Should Be    ${book}[title]    reading

    Change Book Status    ${book}[title]    to_read
    Book Status Should Be    ${book}[title]    to_read

Reading Stats Increment When Status Changes To Reading
    [Documentation]    O contador "Lendo" no dashboard incrementa
    ...                quando um livro tem seu status alterado para "reading"
    [Tags]    positive    books    ui    status    statistics    ID=BSTAT004

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
    [Tags]    positive    books    ui    status    statistics    ID=BSTAT005

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
    [Tags]    positive    books    ui    status    ID=BSTAT006

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Book Status Should Be    ${book}[title]    to_read

Status Change Persists After Page Reload
    [Documentation]    Alteração de status persiste após recarregar a página
    [Tags]    positive    books    ui    status    persistence    ID=BSTAT007

    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Change Book Status    ${book}[title]    reading

    Reload
    Wait For Load State    networkidle
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=15s

    Book Status Should Be    ${book}[title]    reading