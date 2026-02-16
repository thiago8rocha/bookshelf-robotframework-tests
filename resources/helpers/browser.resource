*** Settings ***
Library    Browser

*** Variables ***
${HEADLESS}        ${TRUE}
${BROWSER_TYPE}    chromium
${VIEWPORT_WIDTH}  1280
${VIEWPORT_HEIGHT} 800
${MOBILE_DEVICE}   iPhone 13

*** Keywords ***

Open Desktop Browser
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS}
    New Context    viewport={'width': ${VIEWPORT_WIDTH}, 'height': ${VIEWPORT_HEIGHT}}
    New Page

Open Mobile Browser
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS}
    New Context    device=${MOBILE_DEVICE}
    New Page

Open Browser To URL
    [Arguments]    ${url}
    Open Desktop Browser
    Go To    ${url}

Open Mobile Browser To URL
    [Arguments]    ${url}
    Open Mobile Browser
    Go To    ${url}

Close Browser Session
    Close Browser