*** Settings ***
Library    Browser

*** Keywords ***

Wait For Page Ready
    Wait For Load State    load

Click Safely
    [Arguments]    ${selector}
    Wait For Elements State    ${selector}    visible
    Click    ${selector}

Fill Safely
    [Arguments]    ${selector}    ${text}
    Wait For Elements State    ${selector}    visible
    Fill Text    ${selector}    ${text}

Element Should Be Visible
    [Arguments]    ${selector}
    Wait For Elements State    ${selector}    visible

Element Should Contain Text
    [Arguments]    ${selector}    ${text}
    ${content}=    Get Text    ${selector}
    Should Contain    ${content}    ${text}

Take Screenshot
    Take Screenshot
