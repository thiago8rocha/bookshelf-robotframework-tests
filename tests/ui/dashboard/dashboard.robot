*** Settings ***
Documentation    Testes de dashboard e estatísticas
...
...    Valida que o dashboard exibe corretamente os contadores de livros
...    e que os dados são atualizados em tempo real conforme ações do usuário.

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource
Resource    ../../../resources/helpers/common/data.resource

Suite Setup      Ensure Default User Exists
Test Setup       Setup UI Test
Test Teardown    Teardown UI Test


*** Test Cases ***

New User Dashboard Starts With Zero Stats
    [Documentation]    Usuário recém-registrado vê todos os contadores zerados.
    ...                Valida o estado inicial limpo do dashboard.
    [Tags]    positive    dashboard    statistics    ui    ID=DASH001

    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]

    Wait For Elements State    data-testid=stats-total      visible    timeout=10s
    Wait For Elements State    data-testid=stats-reading    visible    timeout=10s

    ${total}=    Get Text    data-testid=stats-total
    ${reading}=    Get Text    data-testid=stats-reading

    Should Contain    ${total}      0
    Should Contain    ${reading}    0

Stats Total Increments When Book Is Created
    [Documentation]    O contador total aumenta em 1 a cada livro criado.
    [Tags]    positive    dashboard    statistics    ui    ID=DASH002

    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]

    ${antes}=    Get Text    data-testid=stats-total
    Should Contain    ${antes}    0

    # Criar primeiro livro
    ${book1}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book1}[title]
    Fill Text    id=author    ${book1}[author]
    Click Save Book Button

    ${apos_um}=    Get Text    data-testid=stats-total
    Should Contain    ${apos_um}    1

    # Criar segundo livro
    ${book2}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book2}[title]
    Fill Text    id=author    ${book2}[author]
    Click Save Book Button

    ${apos_dois}=    Get Text    data-testid=stats-total
    Should Contain    ${apos_dois}    2

Stats Total Decrements When Book Is Deleted
    [Documentation]    O contador total diminui em 1 a cada livro excluído.
    [Tags]    positive    dashboard    statistics    ui    ID=DASH003

    # Setup via API: usuário com 2 livros
    ${credentials}=    Generate Unique User Credentials
    ${resp}=           Create User Via API    ${credentials}
    Should Be Equal As Integers    ${resp.status_code}    201
    ${token}=          Login Via API    ${credentials}[email]    ${credentials}[password]

    ${book1}=    Generate Book With Required Fields Only
    ${book2}=    Generate Book With Required Fields Only
    Create Book Via API    ${book1}    ${token}
    Create Book Via API    ${book2}    ${token}

    Login With Credentials    ${credentials}[email]    ${credentials}[password]

    ${antes}=    Get Text    data-testid=stats-total
    Should Contain    ${antes}    2

    # Excluir um livro
    User Deletes Book    ${book1}[title]

    ${apos_delete}=    Get Text    data-testid=stats-total
    Should Contain    ${apos_delete}    1

    # Excluir o segundo
    User Deletes Book    ${book2}[title]

    ${apos_todos}=    Get Text    data-testid=stats-total
    Should Contain    ${apos_todos}    0

Stats Are Specific To Each User
    [Documentation]    Os contadores do dashboard refletem apenas os livros
    ...                do usuário logado, não os de outros usuários.
    [Tags]    positive    dashboard    statistics    security    ui    ID=DASH004

    # Usuário A: 3 livros via API
    ${user_a}=     Generate Unique User Credentials
    ${resp_a}=     Create User Via API    ${user_a}
    Should Be Equal As Integers    ${resp_a.status_code}    201
    ${token_a}=    Login Via API    ${user_a}[email]    ${user_a}[password]
    FOR    ${i}    IN RANGE    3
        ${book}=    Generate Book With Required Fields Only
        Create Book Via API    ${book}    ${token_a}
    END

    # Usuário B: 1 livro via API
    ${user_b}=     Generate Unique User Credentials
    ${resp_b}=     Create User Via API    ${user_b}
    Should Be Equal As Integers    ${resp_b.status_code}    201
    ${token_b}=    Login Via API    ${user_b}[email]    ${user_b}[password]
    ${book_b}=     Generate Book With Required Fields Only
    Create Book Via API    ${book_b}    ${token_b}

    # B vê apenas os seus próprios stats
    Login With Credentials    ${user_b}[email]    ${user_b}[password]
    ${total_b}=    Get Text    data-testid=stats-total
    Should Contain    ${total_b}    1

Dashboard Displays Book List
    [Documentation]    Os livros criados aparecem listados no dashboard.
    ...                Valida que a lista e os stats estão sincronizados.
    [Tags]    positive    dashboard    ui    ID=DASH005

    # Setup: usuário com 2 livros via API
    ${credentials}=    Generate Unique User Credentials
    ${resp}=           Create User Via API    ${credentials}
    Should Be Equal As Integers    ${resp.status_code}    201
    ${token}=          Login Via API    ${credentials}[email]    ${credentials}[password]

    ${book1}=    Generate Book With Required Fields Only
    ${book2}=    Generate Book With Required Fields Only
    Create Book Via API    ${book1}    ${token}
    Create Book Via API    ${book2}    ${token}

    Login With Credentials    ${credentials}[email]    ${credentials}[password]

    # Ambos os livros aparecem na lista
    Book Should Exist In List    ${book1}[title]
    Book Should Exist In List    ${book2}[title]

    # Stats batem com a lista
    ${total}=    Get Text    data-testid=stats-total
    Should Contain    ${total}    2

Stats Update Is Immediate After Action
    [Documentation]    Os contadores são atualizados imediatamente após criar ou excluir
    ...                um livro, sem necessidade de recarregar a página.
    [Tags]    positive    dashboard    statistics    ui    ID=DASH006

    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]

    # Criar livro e verificar stats sem recarregar
    ${book}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book}[title]
    Fill Text    id=author    ${book}[author]
    Click Save Book Button

    ${total_criado}=    Get Text    data-testid=stats-total
    Should Contain    ${total_criado}    1

    # Excluir e verificar stats sem recarregar
    User Deletes Book    ${book}[title]

    ${total_deletado}=    Get Text    data-testid=stats-total
    Should Contain    ${total_deletado}    0
