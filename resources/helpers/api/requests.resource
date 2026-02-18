*** Settings ***
Documentation    Keywords genéricas para requisições HTTP
...              Suporta autenticação opcional via token

Library     RequestsLibrary
Library     Collections

*** Keywords ***

# ==========================================
# HTTP METHODS (WITHOUT AUTH)
# ==========================================

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

# ==========================================
# HTTP METHODS (WITH AUTH)
# ==========================================

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

# ==========================================
# VALIDATIONS
# ==========================================

Response Status Should Be
    [Documentation]    Valida o status code da resposta
    [Arguments]    ${response}    ${expected}
    Should Be Equal As Integers    ${response.status_code}    ${expected}

Response Should Contain Key
    [Documentation]    Valida que a resposta JSON contém uma chave (suporta nested keys)
    [Arguments]    ${response}    ${key}
    
    ${json}=    Set Variable    ${response.json()}
    
    # Se a chave tiver ponto (ex: stats.total), fazer drill-down
    ${has_dot}=    Run Keyword And Return Status    Should Contain    ${key}    .
    
    IF    ${has_dot}
        ${keys}=    Split String    ${key}    .
        FOR    ${k}    IN    @{keys}
            ${json}=    Get From Dictionary    ${json}    ${k}
        END
    ELSE
        Should Contain    ${json}    ${key}
    END

Response Should Not Contain Key
    [Documentation]    Valida que a resposta JSON NÃO contém uma chave
    [Arguments]    ${response}    ${key}
    Should Not Contain    ${response.json()}    ${key}

Response JSON Should Match
    [Documentation]    Valida estrutura completa da resposta JSON
    [Arguments]    ${response}    ${expected_dict}
    ${actual}=    Set Variable    ${response.json()}
    Dictionaries Should Be Equal    ${actual}    ${expected_dict}