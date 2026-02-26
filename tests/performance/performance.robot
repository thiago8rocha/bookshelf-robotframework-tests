*** Settings ***
Documentation
...    Testes de Performance — Bookshelf API
...
...    Valida que os endpoints de autenticação e livros
...    respondem dentro dos thresholds sob carga normal.

Resource    ../../resources/helpers/performance/k6.resource

Suite Setup       Setup Performance Suite
Suite Teardown    Teardown Performance Suite


*** Variables ***
${SCRIPTS_DIR}    ${EXECDIR}/tests/performance/k6


*** Test Cases ***

Auth Endpoints Should Meet Performance Thresholds
    [Documentation]
    ...    Load test dos endpoints de autenticação.
    ...    Valida que register e login respondem dentro dos thresholds
    ...    sob carga normal de 10 VUs.
    [Tags]    performance    load    auth
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/auth_performance.js
    ...    output=auth_performance
    ...    test_type=load
    K6 Should Pass    ${result}
    Attach Performance Results To Allure    ${result}    Auth — Load Test

Books Endpoints Should Meet Performance Thresholds
    [Documentation]
    ...    Load test do CRUD de livros.
    ...    Valida que list e create respondem dentro dos thresholds
    ...    sob carga normal de 10 VUs.
    [Tags]    performance    load    books
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/books_performance.js
    ...    output=books_performance
    ...    test_type=load
    K6 Should Pass    ${result}
    Attach Performance Results To Allure    ${result}    Books — Load Test
