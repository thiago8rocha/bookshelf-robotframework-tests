*** Settings ***
Resource    ../../../resources/base/ui_base.resource

*** Test Cases ***
User Can Create Book
    Login As Valid User
    ${title}=    Set Variable    Robot Book
    User Creates Book    ${title}