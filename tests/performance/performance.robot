*** Settings ***
Documentation
...    Testes de Performance — Bookshelf API
...
...    Tipos de teste cobertos:
...    • Load   — carga normal (baseline)
...    • Spike  — pico súbito de usuários
...    • Soak   — carga sustentada longa (detecta degradação)
...    • Stress — escalonamento até o ponto de ruptura
...
...    Cada teste executa o script K6 correspondente, valida os
...    thresholds via exit code e gera attachment no relatório Allure.

Resource    ../../resources/helpers/performance/k6.resource

Suite Setup       Setup Performance Suite
Suite Teardown    Teardown Performance Suite


*** Variables ***
${SCRIPTS_DIR}    ${EXECDIR}/tests/performance/k6


*** Test Cases ***

# ===========================================================
# LOAD TESTS — baseline de comportamento normal
# ===========================================================

Auth Endpoints Should Meet Performance Thresholds
    [Documentation]
    ...    Load test dos endpoints de autenticação.
    ...    Valida que register e login respondem dentro dos thresholds
    ...    sob carga normal de 10 VUs.
    [Tags]    performance    load    auth
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/auth_load.js
    ...    output=auth_load
    ...    test_type=load
    Attach Performance Results To Allure    ${result}    Auth — Load Test
    K6 Should Pass    ${result}

Books Endpoints Should Meet Performance Thresholds
    [Documentation]
    ...    Load test do CRUD de livros.
    ...    Valida que list, create, update e delete respondem
    ...    dentro dos thresholds sob carga normal de 10 VUs.
    [Tags]    performance    load    books
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/books_load.js
    ...    output=books_load
    ...    test_type=load
    Attach Performance Results To Allure    ${result}    Books — Load Test
    K6 Should Pass    ${result}


# ===========================================================
# SPIKE TESTS — pico súbito
# ===========================================================

Auth Endpoints Should Recover After Traffic Spike
    [Documentation]
    ...    Spike test dos endpoints de autenticação.
    ...    Simula um pico súbito de 2 → 50 VUs e verifica que
    ...    o sistema continua operacional e se recupera após o pico.
    [Tags]    performance    spike    auth
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/auth_spike.js
    ...    output=auth_spike
    ...    test_type=spike
    Attach Performance Results To Allure    ${result}    Auth — Spike Test
    K6 Should Pass    ${result}

Books Endpoints Should Recover After Traffic Spike
    [Documentation]
    ...    Spike test do CRUD de livros.
    ...    Simula pico súbito de 2 → 50 VUs no CRUD e verifica
    ...    estabilidade e recuperação após o pico.
    [Tags]    performance    spike    books
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/books_spike.js
    ...    output=books_spike
    ...    test_type=spike
    Attach Performance Results To Allure    ${result}    Books — Spike Test
    K6 Should Pass    ${result}


# ===========================================================
# SOAK TESTS — carga sustentada
# ===========================================================

Auth Endpoints Should Not Degrade Under Sustained Load
    [Documentation]
    ...    Soak test dos endpoints de autenticação.
    ...    Mantém 5 VUs por ~12 minutos para detectar memory leaks
    ...    e degradação gradual de performance.
    [Tags]    performance    soak    auth    slow
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/auth_soak.js
    ...    output=auth_soak
    ...    test_type=soak
    Attach Performance Results To Allure    ${result}    Auth — Soak Test
    K6 Should Pass    ${result}

Books Endpoints Should Not Degrade Under Sustained Load
    [Documentation]
    ...    Soak test do CRUD de livros.
    ...    Mantém 5 VUs por ~12 minutos para detectar memory leaks
    ...    e degradação gradual no CRUD.
    [Tags]    performance    soak    books    slow
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/books_soak.js
    ...    output=books_soak
    ...    test_type=soak
    Attach Performance Results To Allure    ${result}    Books — Soak Test
    K6 Should Pass    ${result}


# ===========================================================
# STRESS TESTS — ponto de ruptura
# ===========================================================

Auth Endpoints Should Document Breaking Point
    [Documentation]
    ...    Stress test dos endpoints de autenticação.
    ...    Escala progressivamente de 10 → 80 VUs para identificar
    ...    o ponto de ruptura e documentar o comportamento sob stress.
    ...    Uma falha nos thresholds é esperada e documentada — não
    ...    indica bug, mas sim o limite do sistema.
    [Tags]    performance    stress    auth
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/auth_stress.js
    ...    output=auth_stress
    ...    test_type=stress
    Attach Performance Results To Allure    ${result}    Auth — Stress Test
    K6 Should Pass    ${result}

Books Endpoints Should Document Breaking Point
    [Documentation]
    ...    Stress test do CRUD de livros.
    ...    Escala progressivamente de 10 → 80 VUs para identificar
    ...    o ponto de ruptura do CRUD.
    [Tags]    performance    stress    books
    ${result}=    Run K6 Test
    ...    script=${SCRIPTS_DIR}/books_stress.js
    ...    output=books_stress
    ...    test_type=stress
    Attach Performance Results To Allure    ${result}    Books — Stress Test
    K6 Should Pass    ${result}
