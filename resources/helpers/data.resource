*** Settings ***
Library    OperatingSystem
Library    Collections

*** Keywords ***
Load JSON Fixture
    [Arguments]    ${fixture_name}
    ${json_string}=    Get File    ${CURDIR}/../fixtures/${fixture_name}.json
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

Generate Random Email
    ${timestamp}=    Get Time    epoch
    ${email}=    Set Variable    test${timestamp}@test.com
    RETURN    ${email}

Generate Random Book Title
    ${timestamp}=    Get Time    epoch
    ${title}=    Set Variable    Test Book ${timestamp}
    RETURN    ${title}