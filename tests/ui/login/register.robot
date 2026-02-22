*** Settings ***
Documentation    Testes positivos de registro de usuário
...              Valida fluxo de criação de nova conta

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/register.resource
Resource    ../../../resources/helpers/common/data.resource

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
    Error Message Should Be Visible    já existe

User Cannot Register With Short Password
    [Documentation]    Valida tamanho mínimo de senha
    [Tags]    negative    auth    ui    validation    ID=REGISTER003
    
    Navigate To Register Page
    Fill Register Name    Test User
    Fill Register Email    newuser@test.com
    Fill Register Password    123
    Click Register Button
    ${has_minlength}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=password-input    minlength
    Should Be True    ${has_minlength}

User Cannot Register With Empty Fields
    [Documentation]    Valida campos obrigatórios
    [Tags]    negative    auth    ui    validation    ID=REGISTER004
    
    Navigate To Register Page
    Click Register Button
    
    ${has_name_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=name-input    required
    ${has_email_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=email-input    required
    ${has_pass_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=password-input    required
    
    Should Be True    ${has_name_required}
    Should Be True    ${has_email_required}
    Should Be True    ${has_pass_required}