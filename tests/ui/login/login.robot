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
    [Documentation]    Valida rejeição de email inválido
    [Tags]    negative    login    ui    validation    ID=LOGIN002
    
    ${fake_email}=    Generate Random Email
    
    Navigate To Login Page
    Fill Email       ${fake_email}
    Fill Password    AnyPassword123!
    Click Login
    
    ${url}=    Get Url
    Should Contain    ${url}    /login

User Cannot Login With Invalid Password
    [Documentation]    Valida rejeição de senha incorreta
    [Tags]    negative    login    ui    validation    ID=LOGIN003
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    
    Navigate To Login Page
    Fill Email       ${credentials}[email]
    Fill Password    WrongPassword123!
    Click Login
    
    ${url}=    Get Url
    Should Contain    ${url}    /login

User Cannot Login With Empty Email
    [Documentation]    Valida campo obrigatório
    [Tags]    negative    login    ui    validation    required    ID=LOGIN004
    
    Navigate To Login Page
    Fill Password    AnyPassword123!
    
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=email-input    required
    Should Be True    ${has_required}

User Cannot Login With Empty Password
    [Documentation]    Valida campo obrigatório
    [Tags]    negative    login    ui    validation    required    ID=LOGIN005
    
    Navigate To Login Page
    ${email}=    Generate Random Email
    Fill Email    ${email}
    
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=password-input    required
    Should Be True    ${has_required}

User Cannot Login With Invalid Email Format
    [Documentation]    Valida formato de email
    [Tags]    negative    login    ui    validation    email    ID=LOGIN006
    
    Navigate To Login Page
    
    Fill Text    data-testid=email-input    invalid-email-format
    Fill Password    Password123!
    
    ${input_type}=    Get Attribute    data-testid=email-input    type
    Should Be Equal    ${input_type}    email

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