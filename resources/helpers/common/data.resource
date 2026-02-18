*** Settings ***
Documentation    Keywords de dados compartilhadas entre API e UI
...              Geração de dados aleatórios e fixtures

Library    OperatingSystem
Library    Collections

*** Keywords ***

# ==========================================
# FIXTURES (JSON FILES)
# ==========================================

Load JSON Fixture
    [Documentation]    Carrega dados de um arquivo JSON de fixture
    [Arguments]    ${fixture_name}
    ${json_string}=    Get File    ${CURDIR}/../../fixtures/${fixture_name}.json
    ${data}=    Evaluate    json.loads('''${json_string}''')    json
    RETURN    ${data}

Get Valid User
    ${users}=    Load JSON Fixture    users
    RETURN    ${users['valid_user']}

Get Admin User
    ${users}=    Load JSON Fixture    users
    RETURN    ${users['admin_user']}

Get Invalid Users
    ${users}=    Load JSON Fixture    users
    RETURN    ${users['invalid_users']}

Get Valid Book
    [Arguments]    ${index}=0
    ${books}=    Load JSON Fixture    books
    ${book}=    Get From List    ${books['valid_books']}    ${index}
    RETURN    ${book}

Get All Valid Books
    ${books}=    Load JSON Fixture    books
    RETURN    ${books['valid_books']}

Get Invalid Book
    [Arguments]    ${index}=0
    ${books}=    Load JSON Fixture    books
    ${book}=    Get From List    ${books['invalid_books']}    ${index}
    RETURN    ${book}

# ==========================================
# RANDOM DATA GENERATION
# ==========================================

Generate Random Email
    [Documentation]    Gera email aleatório usando timestamp
    ${timestamp}=    Get Time    epoch
    ${email}=    Set Variable    test${timestamp}@test.com
    RETURN    ${email}

Generate Random Book Title
    [Documentation]    Gera título de livro aleatório
    ${timestamp}=    Get Time    epoch
    ${title}=    Set Variable    Test Book ${timestamp}
    RETURN    ${title}

Generate Random String
    [Documentation]    Gera string aleatória
    [Arguments]    ${length}=10
    ${timestamp}=    Get Time    epoch
    ${random}=    Set Variable    ${timestamp}
    RETURN    ${random}

Generate Random Number
    [Documentation]    Gera número aleatório
    [Arguments]    ${min}=1    ${max}=1000
    ${timestamp}=    Get Time    epoch
    ${number}=    Evaluate    int(${timestamp}) % (${max} - ${min}) + ${min}
    RETURN    ${number}