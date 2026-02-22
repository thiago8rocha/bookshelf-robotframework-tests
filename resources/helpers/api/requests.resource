*** Settings ***
Documentation    Keywords genéricas para requisições HTTP

Resource    ../../../base/api.resource

*** Keywords ***

GET Endpoint
    [Documentation]    Realiza requisição GET sem autenticação
    [Arguments]    ${endpoint}
    ${response}=    GET On Session    bookshelf_api    ${endpoint}    expected_status=any
    RETURN    ${response}

POST Endpoint
    [Documentation]    Realiza requisição POST sem autenticação
    [Arguments]    ${endpoint}    ${body}
    ${response}=    POST On Session    bookshelf_api    ${endpoint}    json=${body}    expected_status=any
    RETURN    ${response}

PUT Endpoint
    [Documentation]    Realiza requisição PUT sem autenticação
    [Arguments]    ${endpoint}    ${body}
    ${response}=    PUT On Session    bookshelf_api    ${endpoint}    json=${body}    expected_status=any
    RETURN    ${response}

DELETE Endpoint
    [Documentation]    Realiza requisição DELETE sem autenticação
    [Arguments]    ${endpoint}
    ${response}=    DELETE On Session    bookshelf_api    ${endpoint}    expected_status=any
    RETURN    ${response}

GET Authenticated
    [Documentation]    Realiza requisição GET com token de autenticação
    [Arguments]    ${endpoint}    ${token}
    &{headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    bookshelf_api    ${endpoint}    headers=${headers}    expected_status=any
    RETURN    ${response}

POST Authenticated
    [Documentation]    Realiza requisição POST com token de autenticação
    [Arguments]    ${endpoint}    ${body}    ${token}
    &{headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    POST On Session    bookshelf_api    ${endpoint}    json=${body}    headers=${headers}    expected_status=any
    RETURN    ${response}

PUT Authenticated
    [Documentation]    Realiza requisição PUT com token de autenticação
    [Arguments]    ${endpoint}    ${body}    ${token}
    &{headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PUT On Session    bookshelf_api    ${endpoint}    json=${body}    headers=${headers}    expected_status=any
    RETURN    ${response}

PATCH Authenticated
    [Documentation]    Realiza requisição PATCH com token de autenticação
    [Arguments]    ${endpoint}    ${body}    ${token}
    &{headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    PATCH On Session    bookshelf_api    ${endpoint}    json=${body}    headers=${headers}    expected_status=any
    RETURN    ${response}

DELETE Authenticated
    [Documentation]    Realiza requisição DELETE com token de autenticação
    [Arguments]    ${endpoint}    ${token}
    &{headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    DELETE On Session    bookshelf_api    ${endpoint}    headers=${headers}    expected_status=any
    RETURN    ${response}

Response Status Should Be
    [Documentation]    Valida o status code da resposta
    [Arguments]    ${response}    ${expected}
    Should Be Equal As Integers    ${response.status_code}    ${expected}

Response Should Contain Key
    [Documentation]    Valida que a resposta JSON contém uma chave
    [Arguments]    ${response}    ${key}
    
    ${json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${json}    ${key}

Response Should Not Contain Key
    [Documentation]    Valida que a resposta JSON NÃO contém uma chave
    [Arguments]    ${response}    ${key}
    
    ${json}=    Set Variable    ${response.json()}
    ${has_key}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json}    ${key}
    Should Not Be True    ${has_key}

Response JSON Should Match
    [Documentation]    Valida estrutura completa da resposta JSON
    [Arguments]    ${response}    ${expected_dict}
    ${actual}=    Set Variable    ${response.json()}
    Dictionaries Should Be Equal    ${actual}    ${expected_dict}
