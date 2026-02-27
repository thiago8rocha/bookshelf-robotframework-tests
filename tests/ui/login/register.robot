*** Settings ***
Documentation    Testes positivos de registro de usuário
...              Valida fluxo de criação de nova conta

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/register.resource
Resource    ../../../resources/helpers/common/data.resource

Suite Setup    Ensure Default User Exists
Test Setup       Setup UI Test
Test Teardown    Teardown UI Test

*** Test Cases ***

User Can Register With Valid Data
    [Documentation]    Valida que novo usuário consegue criar conta com dados válidos
    [Tags]    smoke    positive    auth    ui    critical    ID=REGISTER001
    
    ${email}=    Generate Random Email
    Navigate To Register Page
    Fill Register Name    Test User
    Fill Register Email    ${email}
    Fill Register Password    123456
    Click Register Button
    Register Should Be Successful

User Cannot Register With Existing Email
    [Documentation]    Valida rejeição de email duplicado
    [Tags]    negative    auth    ui    regression    ID=REGISTER002
    
    Navigate To Register Page
    Fill Register Name    Test User
    Fill Register Email    ${USER_EMAIL}
    Fill Register Password    123456
    Click Register Button
    Error Message Should Be Visible    já cadastrado

User Cannot Register With Short Password
    [Documentation]    Senha com menos de 6 caracteres não completa o registro
    ...                O browser bloqueia via atributo minlength=6 no input
    [Tags]    negative    auth    ui    validation    ID=REGISTER003
    
    ${email}=    Generate Random Email
    Navigate To Register Page
    Fill Register Name      Test User
    Fill Register Email     ${email}
    Fill Register Password  123
    Click Register Button
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}
    
    ${url}=    Get Url
    Should Contain    ${url}    /register

User Cannot Register With Empty Fields
    [Documentation]    Submeter registro com campos vazios não navega para o dashboard
    ...                O browser bloqueia o submit via validação nativa dos campos required
    [Tags]    negative    auth    ui    validation    ID=REGISTER004
    
    Navigate To Register Page
    Click Register Button
    
    ${dashboard_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    data-testid=dashboard-page    visible    timeout=2s
    Should Not Be True    ${dashboard_visible}
    
    ${url}=    Get Url
    Should Contain    ${url}    /register