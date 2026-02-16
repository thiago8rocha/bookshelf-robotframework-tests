*** Settings ***
Resource    ../../../base/ui_base.resource
Resource    ../../../resources/pages/register.resource

*** Test Cases ***
User Cannot Register With Existing Email
    [Tags]    negative    auth    ui
    Navigate To Register Page
    Fill Register Name    Test User
    Fill Register Email    ${USER_EMAIL}
    Fill Register Password    123456
    Click Register Button
    Error Message Should Be Visible    já existe

User Cannot Register With Short Password
    [Tags]    negative    auth    ui
    Navigate To Register Page
    Fill Register Name    Test User
    Fill Register Email    newuser@test.com
    Fill Register Password    123
    Click Register Button
    # HTML5 minlength validation
    Get Attribute    data-testid=password-input    minlength    ==    6

User Cannot Register With Empty Fields
    [Tags]    negative    auth    ui
    Navigate To Register Page
    Click Register Button
    # Todos os campos são required
    Get Attribute    data-testid=name-input    required    ==    ${True}
    Get Attribute    data-testid=email-input    required    ==    ${True}
    Get Attribute    data-testid=password-input    required    ==    ${True}