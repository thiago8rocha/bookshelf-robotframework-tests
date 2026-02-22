*** Settings ***
Documentation    Keywords de gerenciamento, configuração e inicialização de browser

Resource    ../../../base/ui.resource

*** Keywords ***

Open Browser To URL
    [Documentation]    Abre browser e navega para URL
    [Arguments]    ${url}
    
    New Browser    chromium    headless=${HEADLESS}
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page    ${url}

Wait For Page Ready
    [Documentation]    Aguarda página carregar completamente
    Wait For Load State    load

Element Should Be Visible
    [Documentation]    Valida que elemento está visível na tela
    [Arguments]    ${selector}    ${timeout}=10s
    Wait For Elements State    ${selector}    visible    timeout=${timeout}