*** Settings ***
Documentation    Testes de API para autenticação de usuários

Resource    ../../base/api.resource
Resource    ../../resources/helpers/common/data.resource

Suite Setup    Create API Session

*** Test Cases ***

Should Register New User Successfully
    [Documentation]    Valida registro de novo usuário
    [Tags]    positive    api    auth    register    ID=AUTH001
    
    ${credentials}=    Generate Unique User Credentials
    
    ${body}=    Create Dictionary
    ...         name=${credentials}[name]
    ...         email=${credentials}[email]
    ...         password=${credentials}[password]
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/register
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    201
    
    ${json}=    Set Variable    ${resp.json()}
    Response Should Contain Key    ${resp}    token
    
    Response Should Contain Key    ${resp}    user
    ${user}=    Set Variable    ${json}[user]
    Dictionary Should Contain Key    ${user}    id
    Dictionary Should Contain Key    ${user}    email
    Dictionary Should Contain Key    ${user}    name
    
    Should Be Equal    ${user}[email]    ${credentials}[email]
    Should Be Equal    ${user}[name]     ${credentials}[name]
    
    ${has_password}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${user}    password
    Should Not Be True    ${has_password}

Should Login With Valid Credentials
    [Documentation]    Valida login com credenciais válidas
    [Tags]    positive    api    auth    login    ID=AUTH002
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    
    ${body}=    Create Dictionary
    ...         email=${credentials}[email]
    ...         password=${credentials}[password]
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/login
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    200
    
    ${json}=    Set Variable    ${resp.json()}
    Response Should Contain Key    ${resp}    token
    
    ${token}=    Set Variable    ${json}[token]
    Should Not Be Equal    ${token}    ${EMPTY}

Should Not Login With Invalid Email
    [Documentation]    Valida rejeição de email não cadastrado
    [Tags]    negative    api    auth    login    ID=AUTH003
    
    ${fake_email}=    Generate Random Email
    ${body}=    Create Dictionary
    ...         email=${fake_email}
    ...         password=AnyPassword123!
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/login
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    401
    
    ${json}=    Set Variable    ${resp.json()}
    Response Should Contain Key    ${resp}    error

Should Not Login With Invalid Password
    [Documentation]    Valida rejeição de senha incorreta
    [Tags]    negative    api    auth    login    ID=AUTH004
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    
    ${body}=    Create Dictionary
    ...         email=${credentials}[email]
    ...         password=WrongPassword123!
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/login
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    401

Should Not Register With Existing Email
    [Documentation]    Valida rejeição de email duplicado
    [Tags]    negative    api    auth    register    validation    ID=AUTH005
    
    ${credentials}=    Generate Unique User Credentials
    ${body1}=    Create Dictionary
    ...          name=${credentials}[name]
    ...          email=${credentials}[email]
    ...          password=${credentials}[password]
    
    POST On Session    bookshelf_api
    ...    /api/auth/register
    ...    json=${body1}
    ...    expected_status=201
    
    ${body2}=    Create Dictionary
    ...          name=Another Name
    ...          email=${credentials}[email]
    ...          password=AnotherPass123!
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/register
    ...         json=${body2}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    409
    
    ${json}=    Set Variable    ${resp.json()}
    Response Should Contain Key    ${resp}    error

Should Not Register With Invalid Email Format
    [Documentation]    API não valida formato de email no backend - apenas frontend
    [Tags]    robot:skip    negative    api    auth    register    validation    email    ID=AUTH006

    Skip    Backend não valida formato de email - validação ocorre apenas no frontend

    ${body}=    Create Dictionary
    ...         name=Test User
    ...         email=invalid-email-format
    ...         password=Test123456!
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/register
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    400

Should Not Register Without Email
    [Documentation]    Valida que email é obrigatório
    [Tags]    negative    api    auth    register    validation    ID=AUTH007
    
    ${body}=    Create Dictionary
    ...         name=Test User
    ...         password=Test123456!
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/register
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    400

Should Not Register Without Password
    [Documentation]    Valida que senha é obrigatória
    [Tags]    negative    api    auth    register    validation    ID=AUTH008
    
    ${email}=    Generate Random Email
    ${body}=     Create Dictionary
    ...          name=Test User
    ...          email=${email}
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/register
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    400

Should Not Register Without Name
    [Documentation]    Valida que nome é obrigatório
    [Tags]    negative    api    auth    register    validation    ID=AUTH009
    
    ${email}=    Generate Random Email
    ${body}=     Create Dictionary
    ...          email=${email}
    ...          password=Test123456!
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/register
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    400

Should Not Login Without Email
    [Documentation]    Valida que email é obrigatório no login
    [Tags]    negative    api    auth    login    validation    ID=AUTH010
    
    ${body}=    Create Dictionary
    ...         password=Test123456!
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/login
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    400

Should Not Login Without Password
    [Documentation]    Valida que senha é obrigatória no login
    [Tags]    negative    api    auth    login    validation    ID=AUTH011
    
    ${email}=    Generate Random Email
    ${body}=     Create Dictionary
    ...          email=${email}
    
    ${resp}=    POST On Session    bookshelf_api
    ...         /api/auth/login
    ...         json=${body}
    ...         expected_status=any
    
    Response Status Should Be    ${resp}    400

Valid Token Should Allow Access To Protected Resources
    [Documentation]    Valida que token válido permite acesso
    [Tags]    positive    api    auth    token    integration    ID=AUTH012
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    ${token}=    Login Via API    ${credentials}[email]    ${credentials}[password]
    
    ${resp}=    GET Authenticated    /api/books    ${token}
    
    Response Status Should Be    ${resp}    200

Token Should Be Usable Multiple Times
    [Documentation]    Valida que token pode ser usado múltiplas vezes
    [Tags]    positive    api    auth    token    ID=AUTH013
    
    ${credentials}=    Generate Unique User Credentials
    Create User Via API    ${credentials}
    ${token}=    Login Via API    ${credentials}[email]    ${credentials}[password]
    
    FOR    ${i}    IN RANGE    3
        ${resp}=    GET Authenticated    /api/books    ${token}
        Response Status Should Be    ${resp}    200
    END

Different Users Should Have Different Tokens
    [Documentation]    Valida que usuários diferentes têm tokens diferentes
    [Tags]    positive    api    auth    token    security    ID=AUTH014
    
    ${user1}=    Generate Unique User Credentials
    ${user2}=    Generate Unique User Credentials
    
    Create User Via API    ${user1}
    Create User Via API    ${user2}
    
    ${token1}=    Login Via API    ${user1}[email]    ${user1}[password]
    ${token2}=    Login Via API    ${user2}[email]    ${user2}[password]
    
    Should Not Be Equal    ${token1}    ${token2}