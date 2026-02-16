*** Settings ***
Library    Browser

*** Keywords ***
Fill Email
    [Arguments]    ${email}
    Wait For Elements State    data-testid=email-input    visible
    Fill Text    data-testid=email-input    ${email}

Fill Password
    [Arguments]    ${password}
    Wait For Elements State    data-testid=password-input    visible
    Fill Text    data-testid=password-input    ${password}

Click Login
    Wait For Elements State    data-testid=login-button    enabled
    Click    data-testid=login-button

Error Message Should Be Visible
    [Arguments]    ${message}
    Wait For Elements State    css=.text-red-500    visible
    ${error_text}=    Get Text    css=.text-red-500
    Should Contain    ${error_text}    ${message}

Navigate To Register Page
    Click    text=Cadastre-se grátis
    Wait For Elements State    data-testid=register-page    visible