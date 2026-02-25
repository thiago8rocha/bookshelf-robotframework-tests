*** Settings ***
Documentation    Setup base para testes de UI e Acessibilidade

Library    Browser
Library    String
Library    BuiltIn
Library    DateTime
Library    FakerLibrary    locale=pt_BR
Library    RequestsLibrary

Resource    ../environment.resource
Resource    ../resources/helpers/ui/browser.resource
Resource    ../resources/helpers/common/data.resource

*** Keywords ***

Ensure Default User Exists
    [Documentation]    Garante que o usuário padrão (test@email.com / 123456) existe
    ...                e está funcional no banco antes dos testes de UI rodarem.
    ...                Verifica primeiro via login para evitar erro 409 no backend
    ...                quando o usuário já foi criado por uma suite anterior.
    Create Session    ui_seed    ${API_URL}    verify=${False}
    ${login_body}=    Create Dictionary
    ...    email=${USER_EMAIL}
    ...    password=${USER_PASS}
    ${login_resp}=    POST On Session    ui_seed    /api/auth/login
    ...    json=${login_body}    expected_status=any
    Return From Keyword If    ${login_resp.status_code} == 200
    ${body}=    Create Dictionary
    ...    name=Default UI Test User
    ...    email=${USER_EMAIL}
    ...    password=${USER_PASS}
    ${resp}=    POST On Session    ui_seed    /api/auth/register
    ...    json=${body}    expected_status=any
    Should Be True    ${resp.status_code} == 201
    ...    msg=Falha ao criar usuário padrão: status ${resp.status_code}

Setup UI Test
    [Documentation]    Inicializa browser e contexto para um teste
    Open Browser To URL    ${BASE_URL}
    browser.Wait For Page Ready

Teardown UI Test
    [Documentation]    Fecha browser após o teste
    Close Browser

Setup UI Suite
    [Documentation]    Inicializa browser para toda a suite
    Open Browser To URL    ${BASE_URL}
    browser.Wait For Page Ready

Teardown UI Suite
    [Documentation]    Fecha browser após toda a suite
    Close Browser