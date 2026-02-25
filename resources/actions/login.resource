*** Settings ***
Documentation    Keywords de login

Resource    ../../base/ui.resource
Resource    ../../environment.resource

*** Keywords ***

Navigate To Login Page
    [Documentation]    Navega para página de login
    Go To    ${BASE_URL}/login
    Wait For Elements State    data-testid=login-page    visible    timeout=10s

Fill Email
    [Documentation]    Preenche campo de email
    [Arguments]    ${email}
    Wait For Elements State    data-testid=email-input    visible    timeout=5s
    Fill Text    data-testid=email-input    ${email}

Fill Password
    [Documentation]    Preenche campo de senha
    [Arguments]    ${password}
    Wait For Elements State    data-testid=password-input    visible    timeout=5s
    Fill Text    data-testid=password-input    ${password}

Click Login
    [Documentation]    Clica no botão de login
    Wait For Elements State    data-testid=login-button    enabled    timeout=5s
    Click    data-testid=login-button

Dashboard Should Be Visible
    [Documentation]    Valida que dashboard está visível
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=15s

Login With Credentials
    [Documentation]    Realiza login completo com email e senha fornecidos
    [Arguments]    ${email}    ${password}
    
    Navigate To Login Page
    Fill Email    ${email}
    Fill Password    ${password}
    Click Login
    Dashboard Should Be Visible

Login As Default User
    [Documentation]    Faz login com usuário padrão do environment.resource
    Login With Credentials    ${USER_EMAIL}    ${USER_PASS}

Press Enter On Password Field
    [Documentation]    Pressiona Enter no campo de senha (submete formulário)
    Focus    data-testid=password-input
    Keyboard Key    press    Enter

Press Escape
    [Documentation]    Pressiona tecla Escape
    Keyboard Key    press    Escape

Validate Login Error Message
    [Documentation]    Valida mensagem de erro de login
    [Arguments]    ${message}=incorrect
    
    ${has_error}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=error-message    visible    timeout=5s
    
    IF    ${has_error}
        ${error_text}=    Get Text    data-testid=error-message
        Should Contain    ${error_text}    ${message}
    ELSE
        ${url}=    Get Url
        Should Contain    ${url}    /login
        
        ${dashboard_visible}=    Run Keyword And Return Status
        ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
        Should Be True    not ${dashboard_visible}
    END

Logout
    [Documentation]    Faz logout do usuário
    ${logout_exists}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=logout-button    visible    timeout=2s
    
    IF    ${logout_exists}
        Click    data-testid=logout-button
        Wait For Elements State    data-testid=login-page    visible    timeout=10s
    ELSE
        Log    Logout button not found, trying menu logout
        ${menu_exists}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=[aria-label="menu"]    visible    timeout=2s
        IF    ${menu_exists}
            Click    css=[aria-label="menu"]
            Sleep    0.5s
            Click    text=Logout
            Wait For Elements State    data-testid=login-page    visible    timeout=10s
        ELSE
            ${sair_exists}=    Run Keyword And Return Status
            ...    Wait For Elements State    text=Sair    visible    timeout=2s
            IF    ${sair_exists}
                Click    text=Sair
                Wait For Elements State    data-testid=login-page    visible    timeout=10s
            ELSE
                Fail    Could not find logout mechanism - no logout button, menu or Sair link found
            END
        END
    END

User Should Be Logged In
    [Documentation]    Valida que usuário está logado
    
    ${url}=    Get Url
    Should Contain    ${url}    /dashboard
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=5s

User Should Not Be Logged In
    [Documentation]    Valida que usuário NÃO está logado
    
    ${url}=    Get Url
    ${is_login_or_register}=    Evaluate    '/login' in '${url}' or '/register' in '${url}'
    Should Be True    ${is_login_or_register}
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}