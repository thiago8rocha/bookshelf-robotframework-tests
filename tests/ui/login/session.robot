*** Settings ***
Documentation    Testes de persistência de sessão

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/helpers/common/data.resource

Test Setup    Setup UI Test
Test Teardown    Teardown UI Test

*** Test Cases ***

Session Should Persist After Page Refresh
    [Documentation]    Valida que sessão persiste após recarregar página
    [Tags]    positive    session    persistence    ui    ID=SESSION001
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    User Should Be Logged In
    
    Reload
    Wait For Load State    networkidle
    
    ${url}=    Get Url
    Should Contain    ${url}    /dashboard
    User Should Be Logged In

Session Should Be Cleared After Logout And Refresh
    [Documentation]    Valida que sessão não retorna após logout e reload
    [Tags]    positive    session    logout    security    ID=SESSION002
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    Logout
    User Should Not Be Logged In
    
    Reload
    Wait For Load State    networkidle
    
    ${url}=    Get Url
    Should Contain    ${url}    /login
    User Should Not Be Logged In

Direct Access To Dashboard Without Login Should Redirect To Login
    [Documentation]    Valida redirecionamento ao tentar acessar dashboard sem login
    [Tags]    positive    security    redirect    ui    ID=SESSION003
    
    Go To    ${BASE_URL}/dashboard
    Wait For Load State    networkidle
    
    ${url}=    Get Url
    Should Contain    ${url}    /login

Multiple Tabs Should Share Same Session
    [Documentation]    Valida que sessão é compartilhada entre múltiplas abas
    [Tags]    positive    session    multi-tab    ui    ID=SESSION004
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    Login With Credentials    ${credentials}[email]    ${credentials}[password]
    User Should Be Logged In
    
    New Page    ${BASE_URL}/dashboard
    Wait For Load State    networkidle
    
    ${url}=    Get Url
    Should Contain    ${url}    /dashboard
    User Should Be Logged In