*** Settings ***
Documentation    Gherkin steps for the login feature. Each step wraps the actions in resources/actions/login.resource.

Resource    ../actions/login.resource
Resource    ../helpers/common/data.resource

*** Keywords ***
a registered user
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Set Test Variable    ${CREDENTIALS}    ${credentials}

an unregistered email
    ${email}=    Generate Random Email
    Set Test Variable    ${EMAIL}    ${email}
    Set Test Variable    ${PASSWORD}    AnyPassword123!

the login page is open
    Navigate To Login Page

the user signs in with the right credentials
    Login With Credentials    ${CREDENTIALS}[email]    ${CREDENTIALS}[password]

the user submits the unregistered email
    Fill Email    ${EMAIL}
    Fill Password    ${PASSWORD}
    Click Login

the user submits a wrong password
    Fill Email    ${CREDENTIALS}[email]
    Fill Password    WrongPassword123!
    Click Login

the user submits only a password
    Fill Password    AnyPassword123!
    Click Login

the user submits only an email
    ${email}=    Generate Random Email
    Fill Email    ${email}
    Click Login

the user submits a malformed email
    Fill Text    data-testid=email-input    not-an-email
    Fill Password    Password123!
    Click Login

the dashboard is shown
    Dashboard Should Be Visible
    User Should Be Logged In

the user stays on the login page
    Wait For Elements State    data-testid=login-page    visible    timeout=5s
    ${url}=    Get Url
    Should Contain    ${url}    /login

the dashboard is not shown
    Wait For Elements State    data-testid=dashboard-page    detached    timeout=2s
