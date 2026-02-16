*** Settings ***
Library     RequestsLibrary
Library     Collections

Resource    ../environment.resource

*** Variables ***
${API_SESSION}    bookshelf_api

*** Keywords ***

Create API Session
    Create Session    ${API_SESSION}    ${API_URL}

GET Endpoint
    [Arguments]    ${endpoint}
    ${response}=    GET On Session    ${API_SESSION}    ${endpoint}
    RETURN    ${response}

POST Endpoint
    [Arguments]    ${endpoint}    ${body}
    ${response}=    POST On Session    ${API_SESSION}    ${endpoint}    json=${body}
    RETURN    ${response}

Response Status Should Be
    [Arguments]    ${response}    ${expected}
    Should Be Equal As Integers    ${response.status_code}    ${expected}
