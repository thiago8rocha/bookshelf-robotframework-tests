*** Settings ***
Resource    ../pages/login.resource

*** Keywords ***
Login As Valid User
    Fill Email    ${USER_EMAIL}
    Fill Password    ${USER_PASS}
    Click Login
    Dashboard Should Be Visible

Dashboard Should Be Visible
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=10s
    Get Text    h2    contains    Olá