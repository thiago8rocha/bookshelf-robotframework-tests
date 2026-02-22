*** Settings ***
Documentation    Testes de logout

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource

Test Setup       Run Keywords
...    Setup UI Test
...    Login As Valid User

Test Teardown    Teardown UI Test

*** Test Cases ***

User Can Logout Successfully
    [Documentation]    Valida que usuário consegue fazer logout
    ...                Espera-se redirecionamento para página de login
    [Tags]    smoke    positive    auth    ui    ID=LOGOUT001
    
    Click    text=Sair
    Wait For Elements State    data-testid=login-page    visible    timeout=5s