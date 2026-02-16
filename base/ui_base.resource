*** Settings ***
Resource    ../environment.resource
Resource    ../resources/helpers/browser.resource
Resource    ../resources/helpers/ui.resource

Suite Setup       Setup UI Suite
Suite Teardown    Close Browser Session

*** Keywords ***

Setup UI Suite
    Open Browser To URL    ${BASE_URL}
    Wait For Page Ready