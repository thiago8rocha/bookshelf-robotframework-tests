*** Settings ***
Documentation    Testes de logout

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/helpers/common/data.resource

Test Setup    Setup UI Test
Test Teardown    Teardown UI Test

*** Test Cases ***

User Can Logout Successfully
    [Documentation]    Valida que usuário consegue fazer logout e é redirecionado para login
    [Tags]    positive    logout    ui    session    ID=LOGOUT001
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    User Should Be Logged In
    
    Logout
    
    ${url}=    Get Url
    Should Contain    ${url}    /login
    User Should Not Be Logged In