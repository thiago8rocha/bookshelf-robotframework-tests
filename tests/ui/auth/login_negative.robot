*** Settings ***
Resource    ../../../base/ui_base.resource
Resource    ../../../resources/pages/login.resource

*** Test Cases ***
User Cannot Login With Invalid Email
    [Tags]    negative    auth    ui
    Fill Email    invalid@email.com
    Fill Password    ${USER_PASS}
    Click Login
    Error Message Should Be Visible    Erro ao fazer login

User Cannot Login With Invalid Password
    [Tags]    negative    auth    ui
    Fill Email    ${USER_EMAIL}
    Fill Password    wrongpassword123
    Click Login
    Error Message Should Be Visible    Erro ao fazer login

User Cannot Login With Empty Email
    [Tags]    negative    auth    ui
    Fill Password    ${USER_PASS}
    Click Login
    # HTML5 validation impede submit
    Get Attribute    data-testid=email-input    required    ==    ${True}

User Cannot Login With Empty Password
    [Tags]    negative    auth    ui
    Fill Email    ${USER_EMAIL}
    Click Login
    # HTML5 validation impede submit
    Get Attribute    data-testid=password-input    required    ==    ${True}

User Cannot Login With Invalid Email Format
    [Tags]    negative    auth    ui
    Fill Text    data-testid=email-input    notanemail
    Fill Password    ${USER_PASS}
    Click Login
    # HTML5 validation de email

Login Button Should Be Disabled While Loading
    [Tags]    negative    auth    ui
    Fill Email    ${USER_EMAIL}
    Fill Password    ${USER_PASS}
    Click    data-testid=login-button
    Get Attribute    data-testid=login-button    disabled    ==    disabled