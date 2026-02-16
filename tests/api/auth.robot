*** Settings ***
Resource    ../../base/api_base.resource
Resource    ../../resources/helpers/data.resource

Suite Setup    Create API Session

*** Test Cases ***
Should Register New User Successfully
    [Tags]    smoke    positive    api    auth
    ${email}=    Generate Random Email
    ${body}=    Create Dictionary
    ...    name=API Test User
    ...    email=${email}
    ...    password=123456
    
    ${resp}=    POST Endpoint    /api/auth/register    ${body}
    Response Status Should Be    ${resp}    201
    Should Contain    ${resp.json()}    token
    Should Contain    ${resp.json()}    user

Should Login With Valid Credentials
    [Tags]    positive    api    auth
    ${body}=    Create Dictionary
    ...    email=${USER_EMAIL}
    ...    password=${USER_PASS}
    
    ${resp}=    POST Endpoint    /api/auth/login    ${body}
    Response Status Should Be    ${resp}    200
    Should Contain    ${resp.json()}    token

Should Not Login With Invalid Credentials
    [Tags]    negative    api    auth
    ${body}=    Create Dictionary
    ...    email=invalid@test.com
    ...    password=wrongpass
    
    ${resp}=    Run Keyword And Expect Error    *
    ...    POST Endpoint    /api/auth/login    ${body}
    Should Contain    ${resp}    401