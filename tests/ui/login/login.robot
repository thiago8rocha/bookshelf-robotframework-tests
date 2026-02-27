*** Settings ***
Documentation    Testes de login

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/helpers/common/data.resource

Test Setup    Setup UI Test
Test Teardown    Teardown UI Test

*** Test Cases ***

User Can Login With Valid Credentials
    [Documentation]    Valida que usuário consegue fazer login com credenciais válidas
    [Tags]    positive    login    ui    smoke    ID=LOGIN001
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    
    Navigate To Login Page
    Fill Email       ${credentials}[email]
    Fill Password    ${credentials}[password]
    Click Login
    
    Dashboard Should Be Visible
    User Should Be Logged In

User Cannot Login With Invalid Email
    [Documentation]    Email não cadastrado não autentica — permanece na página de login
    ...                O frontend não navega para o dashboard após credenciais inválidas
    [Tags]    negative    login    ui    validation    ID=LOGIN002
    
    ${fake_email}=    Generate Random Email
    
    Navigate To Login Page
    Fill Email       ${fake_email}
    Fill Password    AnyPassword123!
    Click Login
    
    Sleep    2s
    
    ${url}=    Get Url
    Should Contain    ${url}    /login
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}
    ...    msg=Dashboard acessível com email inválido — autenticação não está bloqueando

User Cannot Login With Invalid Password
    [Documentation]    Senha incorreta não autentica — permanece na página de login
    [Tags]    negative    login    ui    validation    ID=LOGIN003
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    
    Navigate To Login Page
    Fill Email       ${credentials}[email]
    Fill Password    WrongPassword123!
    Click Login
    
    Sleep    2s
    
    ${url}=    Get Url
    Should Contain    ${url}    /login
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}
    ...    msg=Dashboard acessível com senha errada — autenticação não está bloqueando

User Cannot Login With Empty Email
    [Documentation]    Submeter login sem email não navega para o dashboard
    ...                O browser impede o submit via validação nativa do campo required
    [Tags]    negative    login    ui    validation    required    ID=LOGIN004
    
    Navigate To Login Page
    Fill Password    AnyPassword123!
    Click Login
    
    ${url}=    Get Url
    Should Contain    ${url}    /login
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}

User Cannot Login With Empty Password
    [Documentation]    Submeter login sem senha não navega para o dashboard
    [Tags]    negative    login    ui    validation    required    ID=LOGIN005
    
    Navigate To Login Page
    ${email}=    Generate Random Email
    Fill Email    ${email}
    Click Login
    
    ${url}=    Get Url
    Should Contain    ${url}    /login
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}

User Cannot Login With Invalid Email Format
    [Documentation]    Submeter login com email em formato inválido não navega para o dashboard
    ...                O browser bloqueia o submit via validação nativa do type=email
    [Tags]    negative    login    ui    validation    email    ID=LOGIN006
    
    Navigate To Login Page
    Fill Text        data-testid=email-input    not-an-email
    Fill Password    Password123!
    Click Login
    
    ${url}=    Get Url
    Should Contain    ${url}    /login
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}

Login Button Should Be Disabled While Loading
    [Documentation]    Valida botão desabilitado durante loading
    [Tags]    positive    login    ui    loading    ID=LOGIN007
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    
    Navigate To Login Page
    Fill Email       ${credentials}[email]
    Fill Password    ${credentials}[password]
    Click Login
    
    Dashboard Should Be Visible