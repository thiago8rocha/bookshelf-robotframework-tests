*** Settings ***
Documentation    Setup base para testes de API
...              Apenas cria sessão HTTP, autenticação está em helpers/api/

Library     RequestsLibrary
Library     Collections
Library     DateTime

Resource    ../environment.resource
Resource    ../resources/helpers/api/auth.resource
Resource    ../resources/helpers/api/requests.resource
Resource    ../resources/helpers/common/data.resource

*** Variables ***
${API_SESSION}    bookshelf_api

*** Keywords ***

Create API Session
    [Documentation]    Cria sessão HTTP com a API
    Create Session    ${API_SESSION}    ${API_URL}
    Log To Console    ${\n}🌐 API Session created: ${API_URL}