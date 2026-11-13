*** Settings ***
Documentation    API tests for the playground of bugs a user switches on for their own account

Resource    ../../base/api.resource
Resource    ../../resources/helpers/common/data.resource

Suite Setup       Setup Playground API Suite
Suite Teardown    Teardown Playground API Suite

*** Variables ***
${SUITE_USER_TOKEN}     ${EMPTY}
${OTHER_USER_TOKEN}     ${EMPTY}

*** Keywords ***

Setup Playground API Suite
    [Documentation]    Creates the API session and two independent users
    Create API Session
    ${first}=     Generate Unique User Credentials
    ${second}=    Generate Unique User Credentials
    Create User Via API    ${first}
    Create User Via API    ${second}
    ${token_one}=    Login Via API    ${first}[email]     ${first}[password]
    ${token_two}=    Login Via API    ${second}[email]    ${second}[password]
    Set Suite Variable    ${SUITE_USER_TOKEN}    ${token_one}
    Set Suite Variable    ${OTHER_USER_TOKEN}    ${token_two}

Teardown Playground API Suite
    [Documentation]    Switches every bug off and removes the books of both users
    Switch Bugs    ${SUITE_USER_TOKEN}
    Delete All User Books Via API    ${SUITE_USER_TOKEN}
    Delete All User Books Via API    ${OTHER_USER_TOKEN}

Switch Bugs
    [Documentation]    Replaces the set of bugs switched on for the account of the token
    [Arguments]    ${token}    @{enabled}
    ${body}=    Create Dictionary    enabled=${enabled}
    ${resp}=    PUT Authenticated    /api/playground/bugs    ${body}    ${token}
    Response Status Should Be    ${resp}    200

Create Book And Return Status
    [Documentation]    Creates a book for the account of the token and returns the HTTP status
    [Arguments]    ${token}
    ${book}=    Generate Book With Required Fields Only
    ${resp}=    POST Authenticated    /api/books    ${book}    ${token}
    RETURN    ${resp.status_code}

*** Test Cases ***

Should Require Authentication To List The Bugs
    [Documentation]    The playground catalog is only for signed-in users
    [Tags]    negative    api    playground    security    ID=PLAY001

    ${resp}=    GET Endpoint    /api/playground/bugs
    Response Status Should Be    ${resp}    401

Should List The Catalog With Every Bug Off
    [Documentation]    A new account starts with all bugs off
    [Tags]    positive    api    playground    smoke    ID=PLAY002

    ${resp}=    GET Authenticated    /api/playground/bugs    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    200
    ${bugs}=    Set Variable    ${resp.json()}[bugs]
    Should Not Be Empty    ${bugs}
    FOR    ${bug}    IN    @{bugs}
        Should Not Be True    ${bug}[enabled]
    END

Should Reject An Unknown Bug
    [Documentation]    Only ids from the catalog are accepted
    [Tags]    negative    api    playground    validation    ID=PLAY003

    ${body}=    Create Dictionary    enabled=${{ ['does-not-exist'] }}
    ${resp}=    PUT Authenticated    /api/playground/bugs    ${body}    ${SUITE_USER_TOKEN}
    Response Status Should Be    ${resp}    400

Should Answer 200 Instead Of 201 When Creating A Book With The Bug On
    [Documentation]    api-create-book-status-200 changes the status code of the creation
    [Tags]    positive    api    playground    books    ID=PLAY004

    ${normal}=    Create Book And Return Status    ${SUITE_USER_TOKEN}
    Switch Bugs    ${SUITE_USER_TOKEN}    api-create-book-status-200
    ${buggy}=     Create Book And Return Status    ${SUITE_USER_TOKEN}
    Switch Bugs    ${SUITE_USER_TOKEN}
    Should Be Equal As Integers    ${normal}    201
    Should Be Equal As Integers    ${buggy}     200

Should Report One Book Too Many In The Stats With The Bug On
    [Documentation]    api-stats-total-off-by-one inflates the total
    [Tags]    positive    api    playground    stats    ID=PLAY005

    ${before}=    GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    Switch Bugs    ${SUITE_USER_TOKEN}    api-stats-total-off-by-one
    ${after}=     GET Authenticated    /api/stats    ${SUITE_USER_TOKEN}
    Switch Bugs    ${SUITE_USER_TOKEN}
    ${expected}=    Evaluate    ${before.json()}[stats][total] + 1
    Should Be Equal As Integers    ${after.json()}[stats][total]    ${expected}

Should Not Affect Another Account
    [Documentation]    A bug only changes the requests of the account that switched it on
    [Tags]    positive    api    playground    security    ID=PLAY006

    Switch Bugs    ${SUITE_USER_TOKEN}    api-create-book-status-200
    ${other}=    Create Book And Return Status    ${OTHER_USER_TOKEN}
    Switch Bugs    ${SUITE_USER_TOKEN}
    Should Be Equal As Integers    ${other}    201
