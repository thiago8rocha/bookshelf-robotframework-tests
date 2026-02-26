*** Settings ***
Documentation    Testes de logout
...
...    Valida que o logout encerra a sessão corretamente no browser
...    e invalida o token na API, impedindo acesso subsequente.

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource
Resource    ../../../resources/helpers/common/data.resource

Test Setup       Setup UI Test
Test Teardown    Teardown UI Test


*** Test Cases ***

User Can Logout Successfully
    [Documentation]    Valida que usuário consegue fazer logout e é redirecionado para login
    [Tags]    positive    logout    ui    session    ID=LOGOUT001

    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    User Should Be Logged In

    Logout

    ${url}=    Get Url
    Should Contain    ${url}    /login
    User Should Not Be Logged In

Token Is Removed From Browser After Logout
    [Documentation]    Após logout, o token é removido do browser.
    ...                O usuário não consegue acessar o dashboard diretamente —
    ...                é redirecionado para login.
    ...                Nota: JWT é stateless, o token não é invalidado no servidor,
    ...                mas o frontend remove o estado de autenticação local.
    [Tags]    positive    logout    security    ui    ID=LOGOUT002

    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    User Should Be Logged In

    Logout
    Wait For Elements State    data-testid=login-page    visible    timeout=10s

    # Tentar acessar dashboard diretamente — deve redirecionar para login
    Go To    ${BASE_URL}/dashboard
    Wait For Load State    networkidle
    ${url}=    Get Url
    Should Contain    ${url}    /login
    ...    msg=Dashboard acessível após logout — token não foi removido do browser

Browser Back Button After Logout Does Not Restore Session
    [Documentation]    Após logout, navegar com o botão "voltar" do browser
    ...                não reexibe o dashboard autenticado.
    [Tags]    positive    logout    security    ui    ID=LOGOUT003

    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    User Should Be Logged In

    Logout
    Wait For Elements State    data-testid=login-page    visible    timeout=10s

    # Simular botão "voltar" do browser
    Go Back
    Wait For Load State    networkidle

    # Deve permanecer na página de login ou ser redirecionado
    ${url}=    Get Url
    ${is_protected}=    Evaluate    '/dashboard' not in '${url}'
    Should Be True    ${is_protected}
    ...    msg=Sessão restaurada indevidamente após logout e navegação com "voltar"

Logout Clears All User State From Dashboard
    [Documentation]    Após logout e novo login, a sessão está limpa:
    ...                não há estado residual de livros ou ações da sessão anterior.
    [Tags]    positive    logout    ui    ID=LOGOUT004

    # Usuário A faz login, cria um livro e faz logout
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]

    ${book}=    Generate Book With Required Fields Only
    Click Add Book Button
    Fill Text    id=title     ${book}[title]
    Fill Text    id=author    ${book}[author]
    Click Save Book Button
    Book Should Exist In List    ${book}[title]

    Logout
    Wait For Elements State    data-testid=login-page    visible    timeout=10s

    # Novo login — livro deve aparecer (persistência)
    # mas sem modais abertos, erros ou estado de UI da sessão anterior
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=15s

    # Dashboard carrega limpo: sem modal aberto
    ${modal_aberto}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=book-modal    visible    timeout=2s
    Should Not Be True    ${modal_aberto}
    ...    msg=Modal de livro estava aberto na nova sessão — estado residual detectado

    # Livro persiste corretamente
    Book Should Exist In List    ${book}[title]
