*** Settings ***
Resource    ../../base/api_base.resource

Suite Setup    Create API Session

*** Test Cases ***
Should Get Books Without Authentication
    ${resp}=    GET Endpoint    /api/books
    Response Status Should Be    ${resp}    401

Should Register User Successfully
    ${body}=    Create Dictionary
    ...    name=Test User
    ...    email=test${TIMESTAMP}@test.com
    ...    password=123456
    ${resp}=    POST Endpoint    /api/auth/register    ${body}
    Response Status Should Be    ${resp}    201
    Should Contain    ${resp.json()}    token
    Set Suite Variable    ${AUTH_TOKEN}    ${resp.json()['token']}

Should Get Books With Authentication
    &{headers}=    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}
    ${resp}=    GET On Session    ${API_SESSION}    /api/books    headers=${headers}
    Response Status Should Be    ${resp}    200
    Should Contain    ${resp.json()}    books

Should Create Book With Authentication
    &{headers}=    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}
    ${body}=    Create Dictionary
    ...    title=Robot Framework Book
    ...    author=Test Author
    ${resp}=    POST On Session    ${API_SESSION}    /api/books    json=${body}    headers=${headers}
    Response Status Should Be    ${resp}    201
    Should Contain    ${resp.json()}    book

*** Keywords ***
Generate Timestamp
    ${timestamp}=    Get Time    epoch
    RETURN    ${timestamp}