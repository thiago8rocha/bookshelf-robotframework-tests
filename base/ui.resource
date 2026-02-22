*** Settings ***
Documentation    Setup base para testes de UI e Acessibilidade

Library    Browser
Library    String
Library    BuiltIn
Library    DateTime
Library    FakerLibrary    locale=pt_BR

Resource    ../environment.resource
Resource    ../resources/helpers/ui/browser.resource
Resource    ../resources/helpers/common/data.resource

*** Keywords ***

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