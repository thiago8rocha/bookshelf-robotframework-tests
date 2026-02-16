*** Settings ***
Resource    ../../../base/ui_base.resource
Resource    ../../../resources/pages/register.resource
Resource    ../../../resources/helpers/data.resource

*** Test Cases ***
User Can Register Successfully
    [Tags]    smoke    positive    auth    ui
    ${email}=    Generate Random Email
    Navigate To Register Page
    Fill Register Name    Test User
    Fill Register Email    ${email}
    Fill Register Password    123456
    Click Register Button
    Register Should Be Successful