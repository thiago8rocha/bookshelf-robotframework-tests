*** Settings ***
Documentation    Actions para login, registro e autenticação

Resource    ../../base/ui.resource
Resource    ../helpers/common/data.resource

*** Keywords ***

Login As Valid User
    [Documentation]    Login com um usuário padrão (test@email.com)
    Fill Text    data-testid=email-input    ${USER_EMAIL}
    Fill Text    data-testid=password-input    ${USER_PASS}
    Click    data-testid=login-button
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=10s

Register And Login Fresh User
    [Documentation]    Registra NOVO usuário e faz login automaticamente
    
    ${email}=    Generate Random Email
    ${password}=    Set Variable    Test123456!
    ${name}=    Set Variable    Test User
    
    Go To    ${BASE_URL}/register
    Wait For Elements State    data-testid=register-page    visible    timeout=10s
    
    Wait For Elements State    data-testid=name-input    visible    timeout=5s
    Wait For Elements State    data-testid=email-input    visible    timeout=5s
    Wait For Elements State    data-testid=password-input    visible    timeout=5s
    
    Fill Text    data-testid=name-input    ${name}
    Fill Text    data-testid=email-input    ${email}
    Fill Text    data-testid=password-input    ${password}
    
    Wait For Elements State    data-testid=register-button    enabled    timeout=5s
    Click    data-testid=register-button
    
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=15s
    
    Set Test Variable    ${FRESH_USER_EMAIL}    ${email}
    Set Test Variable    ${FRESH_USER_PASS}    ${password}
    
    Log    Novo usuário criado e logado: ${email}
    
    RETURN    ${email}    ${password}

Login With Credentials
    [Arguments]    ${email}    ${password}
    [Documentation]    Login com credenciais específicas
    Fill Text    data-testid=email-input    ${email}
    Fill Text    data-testid=password-input    ${password}
    Click    data-testid=login-button

Login Should Fail With Error
    [Arguments]    ${email}    ${password}    ${error_message}
    [Documentation]    Tenta fazer login e valida que falha com erro esperado
    Fill Text    data-testid=email-input    ${email}
    Fill Text    data-testid=password-input    ${password}
    Click    data-testid=login-button
    
    ${has_error}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=error-message    visible    timeout=3s
    
    IF    ${has_error}
        ${error_text}=    Get Text    data-testid=error-message
        Should Contain    ${error_text}    ${error_message}
    ELSE
        ${url}=    Get Url
        Should Contain    ${url}    /login
    END

Fill Email
    [Arguments]    ${email}
    Wait For Elements State    data-testid=email-input    visible    timeout=5s
    Fill Text    data-testid=email-input    ${email}

Fill Password
    [Arguments]    ${password}
    Wait For Elements State    data-testid=password-input    visible    timeout=5s
    Fill Text    data-testid=password-input    ${password}

Click Login
    Wait For Elements State    data-testid=login-button    enabled    timeout=5s
    Click    data-testid=login-button

Dashboard Should Be Visible
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=10s

Error Message Should Be Visible
    [Arguments]    ${message}
    ${has_error}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=error-message    visible    timeout=3s
    
    IF    ${has_error}
        ${error_text}=    Get Text    data-testid=error-message
        Should Contain    ${error_text}    ${message}
    ELSE
        ${url}=    Get Url
        Should Contain    ${url}    /login
    END