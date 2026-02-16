*** Settings ***
Library    Browser

*** Keywords ***
Navigate To Register Page
    Click    text=Cadastre-se grátis
    Wait For Elements State    data-testid=register-page    visible

Fill Register Name
    [Arguments]    ${name}
    Fill Text    data-testid=name-input    ${name}

Fill Register Email
    [Arguments]    ${email}
    Fill Text    data-testid=email-input    ${email}

Fill Register Password
    [Arguments]    ${password}
    Fill Text    data-testid=password-input    ${password}

Click Register Button
    Click    data-testid=register-button

Register Should Be Successful
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=10s