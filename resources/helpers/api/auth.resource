*** Settings ***
Documentation    Keywords de autenticação para testes de API
...              Gerencia criação de usuários, login e tokens

Resource    ../../../environment.resource
Resource    ../../../base/api.resource
Resource    ../common/data.resource

*** Variables ***
${AUTH_TOKEN}       ${EMPTY}
${TEST_USER_EMAIL}  ${EMPTY}
${TEST_USER_PASS}   test123456

*** Keywords ***

Create Test User And Get Token
    [Documentation]    Cria um novo usuário de teste e retorna o token
    
    ${email}=    Generate Random Email
    Set Suite Variable    ${TEST_USER_EMAIL}    ${email}
    
    ${body}=    Create Dictionary
    ...    name=Test User
    ...    email=${email}
    ...    password=${TEST_USER_PASS}
    
    ${resp}=    POST On Session    bookshelf_api    /api/auth/register    json=${body}    expected_status=any
    
    Should Be Equal As Integers    ${resp.status_code}    201
    Should Contain    ${resp.json()}    token
    
    ${token}=    Set Variable    ${resp.json()['token']}
    Set Suite Variable    ${AUTH_TOKEN}    ${token}
    
    Log To Console    ${\n}Test user created: ${email}
    Log To Console    Token obtained: ${token[:30]}...
    
    RETURN    ${token}

Login With Credentials
    [Documentation]    Faz login com credenciais específicas e retorna o token
    [Arguments]    ${email}    ${password}
    
    ${body}=    Create Dictionary
    ...    email=${email}
    ...    password=${password}
    
    ${resp}=    POST On Session    bookshelf_api    /api/auth/login    json=${body}    expected_status=any
    
    Should Be Equal As Integers    ${resp.status_code}    200
    Should Contain    ${resp.json()}    token
    
    ${token}=    Set Variable    ${resp.json()['token']}
    
    RETURN    ${token}

Login With Default User
    [Documentation]    Faz login com usuário padrão do environment.resource
    
    ${token}=    Login With Credentials    ${USER_EMAIL}    ${USER_PASS}
    Set Suite Variable    ${AUTH_TOKEN}    ${token}
    
    RETURN    ${token}

Get Auth Headers
    [Documentation]    Retorna headers de autenticação com o token atual
    [Arguments]    ${token}=${AUTH_TOKEN}
    
    &{headers}=    Create Dictionary    Authorization=Bearer ${token}
    RETURN    ${headers}