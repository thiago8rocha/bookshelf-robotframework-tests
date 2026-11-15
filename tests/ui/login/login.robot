*** Settings ***
Documentation    Login feature: a registered user signs in, everyone else stays on the login page.

Resource    ../../../base/ui.resource
Resource    ../../../resources/features/login.resource

Test Setup    Setup UI Test
Test Teardown    Teardown UI Test

*** Test Cases ***
Registered User Signs In
    [Tags]    auth    ui    positive    smoke
    Given a registered user
    And the login page is open
    When the user signs in with the right credentials
    Then the dashboard is shown

Unregistered Email Is Rejected
    [Tags]    auth    ui    negative    regression
    Given an unregistered email
    And the login page is open
    When the user submits the unregistered email
    Then the user stays on the login page
    And the dashboard is not shown

Wrong Password Is Rejected
    [Tags]    auth    ui    negative    regression
    Given a registered user
    And the login page is open
    When the user submits a wrong password
    Then the user stays on the login page
    And the dashboard is not shown

Empty Email Is Rejected
    [Tags]    auth    ui    negative    regression
    Given the login page is open
    When the user submits only a password
    Then the user stays on the login page
    And the dashboard is not shown

Empty Password Is Rejected
    [Tags]    auth    ui    negative    regression
    Given the login page is open
    When the user submits only an email
    Then the user stays on the login page
    And the dashboard is not shown

Malformed Email Is Rejected
    [Tags]    auth    ui    negative    regression
    Given the login page is open
    When the user submits a malformed email
    Then the user stays on the login page
    And the dashboard is not shown
