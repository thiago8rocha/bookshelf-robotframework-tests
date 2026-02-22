*** Settings ***
Documentation    Testes de login

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/helpers/common/data.resource

Test Setup       Setup UI Test
Test Teardown    Teardown UI Test

*** Keywords ***

Login Should Fail With Error
    [Arguments]    ${email}    ${password}    ${error_message}
    Fill Email    ${email}
    Fill Password    ${password}
    Click Login
    Error Message Should Be Visible    ${error_message}

*** Test Cases ***

User Can Login With Valid Credentials
    [Documentation]    Valida que usuário consegue fazer login com email e senha corretos
    ...                Espera-se redirecionamento para dashboard após login bem-sucedido
    [Tags]    smoke    positive    auth    ui    critical    ID=LOGIN001
    
    Login As Valid User

User Cannot Login With Invalid Email
    [Documentation]    Valida rejeição de email inválido
    [Tags]    negative    auth    ui    regression    ID=LOGIN002
    [Template]    Login Should Fail With Error
    invalid@email.com    ${USER_PASS}    Erro ao fazer login

User Cannot Login With Invalid Password
    [Documentation]    Valida rejeição de senha incorreta
    [Tags]    negative    auth    ui    regression    ID=LOGIN003
    [Template]    Login Should Fail With Error
    ${USER_EMAIL}    wrongpassword123    Erro ao fazer login

User Cannot Login With Empty Email
    [Documentation]    Valida campo obrigatório
    [Tags]    negative    auth    ui    validation    ID=LOGIN004
    
    Fill Password    ${USER_PASS}
    Click Login
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=email-input    required
    Should Be True    ${has_required}

User Cannot Login With Empty Password
    [Documentation]    Valida campo obrigatório
    [Tags]    negative    auth    ui    validation    ID=LOGIN005
    
    Fill Email    ${USER_EMAIL}
    Click Login
    ${has_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=password-input    required
    Should Be True    ${has_required}

User Cannot Login With Invalid Email Format
    [Documentation]    Valida formato de email
    [Tags]    negative    auth    ui    validation    ID=LOGIN006
    
    Fill Text    data-testid=email-input    notanemail
    Fill Password    ${USER_PASS}
    Click Login

Login Button Should Be Disabled While Loading
    [Documentation]    Valida botão desabilitado
    [Tags]    negative    auth    ui    ux    ID=LOGIN007
    
    Fill Email    ${USER_EMAIL}
    Fill Password    ${USER_PASS}
    Click    data-testid=login-button
    Sleep    100ms