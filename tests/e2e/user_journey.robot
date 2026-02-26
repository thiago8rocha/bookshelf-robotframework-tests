*** Settings ***
Documentation    Testes E2E — Jornadas completas do usuário
...
...    Valida fluxos ponta-a-ponta que atravessam múltiplas
...    funcionalidades em sequência, simulando uso real da aplicação.

Resource    ../../base/ui.resource
Resource    ../../resources/actions/login.resource
Resource    ../../resources/actions/books.resource
Resource    ../../resources/actions/register.resource
Resource    ../../resources/helpers/common/data.resource

Test Setup       Setup UI Test
Test Teardown    Teardown UI Test


*** Test Cases ***

Complete User Journey: Register, Manage Books And Logout
    [Documentation]    Fluxo completo: registro → criação de livros → edição → exclusão → logout.
    ...                Valida que as funcionalidades principais funcionam em sequência
    ...                e que o estado é consistente em cada etapa.
    [Tags]    e2e    journey    smoke    ID=E2E001

    # 1. Registro cria conta e autentica automaticamente
    ${credentials}=    Generate Unique User Credentials
    Navigate To Register Page
    Fill Register Name      ${credentials}[name]
    Fill Register Email     ${credentials}[email]
    Fill Register Password  ${credentials}[password]
    Click Register Button
    Register Should Be Successful

    # 2. Dashboard acessível sem login adicional
    ${url}=    Get Url
    Should Contain    ${url}    /dashboard

    # 3. Biblioteca vazia para usuário novo
    ${total}=    Get Text    data-testid=stats-total
    Should Contain    ${total}    0

    # 4. Criar primeiro livro
    ${book1}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book1}[title]
    Fill Text    id=author    ${book1}[author]
    Click Save Book Button
    Book Should Exist In List    ${book1}[title]

    # 5. Stats refletem a criação
    ${total_apos_criar}=    Get Text    data-testid=stats-total
    Should Contain    ${total_apos_criar}    1

    # 6. Criar segundo livro
    ${book2}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book2}[title]
    Fill Text    id=author    ${book2}[author]
    Click Save Book Button
    Book Should Exist In List    ${book2}[title]

    # 7. Editar o primeiro livro com título completamente diferente
    ${titulo_editado}=    Set Variable    LIVRO EDITADO SUBSTITUIDO
    User Edits Book Title    ${book1}[title]    ${titulo_editado}
    Book Should Exist In List       ${titulo_editado}
    Book Should Not Exist In List   ${book1}[title]

    # 8. Excluir o segundo livro
    User Deletes Book    ${book2}[title]
    Book Should Not Exist In List    ${book2}[title]

    # 9. Stats refletem a exclusão
    ${total_final}=    Get Text    data-testid=stats-total
    Should Contain    ${total_final}    1

    # 10. Logout encerra a sessão corretamente
    Logout
    ${url_final}=    Get Url
    Should Contain    ${url_final}    /login

Users Have Isolated Data
    [Documentation]    Livros criados pelo usuário A não aparecem para o usuário B.
    ...                Valida isolamento de dados entre contas distintas.
    [Tags]    e2e    security    isolation    ID=E2E002

    # Usuário A cria livro via API (setup sem browser)
    ${user_a}=     Generate Unique User Credentials
    ${resp_a}=     Create User Via API    ${user_a}
    Should Be Equal As Integers    ${resp_a.status_code}    201
    ${token_a}=    Login Via API    ${user_a}[email]    ${user_a}[password]
    ${book_a}=     Generate Book With Required Fields Only
    Create Book Via API    ${book_a}    ${token_a}

    # Usuário B registra-se e entra no dashboard via browser
    ${user_b}=    Generate Unique User Credentials
    Navigate To Register Page
    Fill Register Name      ${user_b}[name]
    Fill Register Email     ${user_b}[email]
    Fill Register Password  ${user_b}[password]
    Click Register Button
    Register Should Be Successful

    # B não vê nada do A
    Book Should Not Exist In List    ${book_a}[title]
    ${total_b}=    Get Text    data-testid=stats-total
    Should Contain    ${total_b}    0

    # B cria o próprio livro sem interferência
    ${book_b}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book_b}[title]
    Fill Text    id=author    ${book_b}[author]
    Click Save Book Button
    Book Should Exist In List       ${book_b}[title]
    Book Should Not Exist In List   ${book_a}[title]

Session Persists Across Login, Use And Re-login
    [Documentation]    Dados criados em uma sessão persistem após logout e novo login.
    [Tags]    e2e    session    persistence    ID=E2E003

    # Setup via API
    ${credentials}=    Generate Unique User Credentials
    ${resp}=           Create User Via API    ${credentials}
    Should Be Equal As Integers    ${resp.status_code}    201

    # Primeira sessão: login e criação de livro
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    ${book}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book}[title]
    Fill Text    id=author    ${book}[author]
    Click Save Book Button
    Book Should Exist In List    ${book}[title]

    # Logout
    Logout
    Wait For Elements State    data-testid=login-page    visible    timeout=10s

    # Segunda sessão: livro e stats persistem
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    Book Should Exist In List    ${book}[title]
    ${total}=    Get Text    data-testid=stats-total
    Should Contain    ${total}    1

Register Authenticates User Automatically
    [Documentation]    Após registro, usuário acessa o dashboard diretamente
    ...                sem precisar fazer login manualmente.
    [Tags]    e2e    register    smoke    ID=E2E004

    ${credentials}=    Generate Unique User Credentials
    Navigate To Register Page
    Fill Register Name      ${credentials}[name]
    Fill Register Email     ${credentials}[email]
    Fill Register Password  ${credentials}[password]
    Click Register Button

    # Vai direto para o dashboard — sem etapa de login
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=15s
    ${url}=    Get Url
    Should Contain    ${url}    /dashboard

    # Consegue usar a aplicação imediatamente
    ${book}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book}[title]
    Fill Text    id=author    ${book}[author]
    Click Save Book Button
    Book Should Exist In List    ${book}[title]
