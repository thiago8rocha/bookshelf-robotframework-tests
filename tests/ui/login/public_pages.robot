*** Settings ***
Documentation    Public pages around the sign-in: brand panel, About page, footer and terms

Resource    ../../../base/ui.resource

Test Setup       Setup UI Test
Test Teardown    Teardown UI Test

*** Test Cases ***

Login Shows The Brand Panel And The Footer
    [Documentation]    The sign-in page explains the project before the user signs in
    [Tags]    smoke    positive    auth    ui    public    regression    ID=PUBLIC001

    Go To    ${BASE_URL}/login
    Wait For Elements State    data-testid=login-page    visible    timeout=10s
    Wait For Elements State    data-testid=auth-brand-panel    visible
    Wait For Elements State    data-testid=about-link    visible
    Get Text    data-testid=public-footer    contains    Todos os dados são fictícios

About Page Is Public And Invites To Create An Account
    [Documentation]    The About page opens without signing in and offers the sign-up
    [Tags]    positive    auth    ui    public    regression    ID=PUBLIC002

    Go To    ${BASE_URL}/login
    Wait For Elements State    data-testid=about-link    visible    timeout=10s
    Click    data-testid=about-link
    Wait For Elements State    data-testid=about-page    visible    timeout=10s
    Click    data-testid=about-register-button
    Wait For Elements State    data-testid=register-page    visible    timeout=10s

Terms Page Is Public And Lists Every Section
    [Documentation]    The terms of service open without signing in and show all sections
    [Tags]    positive    auth    ui    public    terms    regression    ID=PUBLIC003

    Go To    ${BASE_URL}/terms
    Wait For Elements State    data-testid=terms-page    visible    timeout=10s
    Get Element Count    css=[data-testid^="terms-section-"]    ==    19
