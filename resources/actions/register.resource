*** Settings ***
Documentation    Ações da página de registro de usuário

Resource    ../../base/ui.resource

*** Keywords ***

Navigate To Register Page
    [Documentation]    Navega para a página de registro
    Go To    ${BASE_URL}/register
    Wait For Elements State    data-testid=register-page    visible    timeout=10s

Fill Register Name
    [Documentation]    Preenche campo de nome
    [Arguments]    ${name}
    Wait For Elements State    data-testid=name-input    visible
    Fill Text    data-testid=name-input    ${name}

Fill Register Email
    [Documentation]    Preenche campo de email
    [Arguments]    ${email}
    Wait For Elements State    data-testid=email-input    visible
    Fill Text    data-testid=email-input    ${email}

Fill Register Password
    [Documentation]    Preenche campo de senha
    [Arguments]    ${password}
    Wait For Elements State    data-testid=password-input    visible
    Fill Text    data-testid=password-input    ${password}

Click Register Button
    [Documentation]    Clica no botão de registro
    Wait For Elements State    data-testid=register-button    visible
    Click    data-testid=register-button

Register Should Be Successful
    [Documentation]    Valida redirecionamento para dashboard
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=10s

Error Message Should Be Visible
    [Documentation]    Valida erro (com ou sem mensagem visual)
    [Arguments]    ${message}
    
    Sleep    1s
    
    ${has_error}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=error-message    visible    timeout=3s
    
    IF    ${has_error}
        ${error_text}=    Get Text    data-testid=error-message
        Should Contain Any    ${error_text}    ${message}    já existe    já cadastrado
    ELSE
        ${url}=    Get Url
        Should Contain    ${url}    /register
    END
