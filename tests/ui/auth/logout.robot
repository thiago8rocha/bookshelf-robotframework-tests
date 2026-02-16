*** Settings ***
Resource    ../../../base/ui_base.resource
Resource    ../../../resources/flows/auth.resource

Test Setup    Login As Valid User

*** Test Cases ***
User Can Logout Successfully
    [Tags]    smoke    positive    auth    ui
    Click    text=Sair
    Wait For Elements State    data-testid=login-page    visible    timeout=5s