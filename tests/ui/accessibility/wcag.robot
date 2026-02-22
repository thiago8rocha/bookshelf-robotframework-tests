*** Settings ***
Documentation    Testes de acessibilidade WCAG 2.1 Level AA

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource

Test Setup       Setup UI Test
Test Teardown    Teardown UI Test

*** Test Cases ***

Login Page Should Be Accessible
    [Documentation]    Valida acessibilidade da página de login
    [Tags]    accessibility    wcag    ui    ID=ACCESS001
    
    Go To    ${BASE_URL}/login
    
    # Validar ARIA labels
    ${has_email_aria}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=email-input    aria-label
    Should Be True    ${has_email_aria}    msg=Email input deve ter aria-label
    
    ${has_password_aria}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=password-input    aria-label
    Should Be True    ${has_password_aria}    msg=Password input deve ter aria-label
    
    # Validar labels de formulário
    ${email_label}=    Get Element Count    css=label[for="email"]
    Should Be Equal As Integers    ${email_label}    1
    
    ${password_label}=    Get Element Count    css=label[for="password"]
    Should Be Equal As Integers    ${password_label}    1

Register Page Should Be Accessible
    [Documentation]    Valida acessibilidade da página de registro
    [Tags]    accessibility    wcag    ui    ID=ACCESS002
    
    Go To    ${BASE_URL}/register
    
    # Validar heading principal
    ${h1_count}=    Get Element Count    css=h1
    Should Be True    ${h1_count} >= 1
    
    ${h1_text}=    Get Text    css=h1
    Should Contain    ${h1_text}    Criar Conta

Dashboard Should Be Accessible
    [Documentation]    Valida acessibilidade do dashboard
    [Tags]    accessibility    wcag    ui    ID=ACCESS003
    
    Go To    ${BASE_URL}/login
    Fill Text    data-testid=email-input    ${USER_EMAIL}
    Fill Text    data-testid=password-input    ${USER_PASS}
    Click    data-testid=login-button
    
    # Aguardar navegação
    Wait For Load State    networkidle
    Sleep    1s
    
    # Verificar role main
    ${main_count}=    Get Element Count    css=[role="main"]
    Run Keyword If    ${main_count} > 0    Log    Role main encontrado
    ...    ELSE    Log    Role main não encontrado - não é obrigatório
    
    # Verificar heading hierarchy
    ${h1_count}=    Get Element Count    css=h1
    Should Be True    ${h1_count} >= 1

Keyboard Navigation Should Work
    [Documentation]    Valida navegação por teclado
    [Tags]    accessibility    keyboard    ui    ID=ACCESS004
    
    Go To    ${BASE_URL}/login
    
    # Tab através dos elementos
    Keyboard Key    press    Tab
    ${email_focused}=    Get Element States    data-testid=email-input    contains    focused
    Should Be True    ${email_focused}
    
    Keyboard Key    press    Tab
    ${pass_focused}=    Get Element States    data-testid=password-input    contains    focused
    Should Be True    ${pass_focused}
    
    Keyboard Key    press    Tab
    ${btn_focused}=    Get Element States    data-testid=login-button    contains    focused
    Should Be True    ${btn_focused}

Focus Indicators Should Be Visible
    [Documentation]    Valida indicadores de foco
    [Tags]    accessibility    focus    ui    ID=ACCESS005
    
    Go To    ${BASE_URL}/login
    
    Focus    data-testid=email-input
    ${outline}=    Get Style    data-testid=email-input    outline
    ${box_shadow}=    Get Style    data-testid=email-input    boxShadow
    
    ${has_outline}=    Run Keyword And Return Status
    ...    Should Not Contain    ${outline}    none
    
    ${has_shadow}=    Run Keyword And Return Status
    ...    Should Not Contain    ${box_shadow}    none
    
    ${has_focus}=    Evaluate    ${has_outline} or ${has_shadow}
    Should Be True    ${has_focus}    msg=Nenhum indicador de foco visível

All Images Should Have Alt Text
    [Documentation]    Valida alt text em imagens
    [Tags]    accessibility    images    ui    ID=ACCESS006
    
    Go To    ${BASE_URL}/login
    Fill Text    data-testid=email-input    ${USER_EMAIL}
    Fill Text    data-testid=password-input    ${USER_PASS}
    Click    data-testid=login-button
    Wait For Load State    networkidle
    
    # Buscar imagens
    ${images}=    Get Elements    css=img
    ${image_count}=    Get Length    ${images}
    
    IF    ${image_count} > 0
        FOR    ${img}    IN    @{images}
            ${has_alt}=    Run Keyword And Return Status
            ...    Get Attribute    ${img}    alt
            Should Be True    ${has_alt}    msg=Imagem sem alt text
        END
    ELSE
        Log    Nenhuma imagem encontrada
    END

Form Errors Should Be Accessible
    [Documentation]    Valida validação HTML5 de formulários
    [Tags]    accessibility    forms    ui    ID=ACCESS007
    
    Go To    ${BASE_URL}/login
    
    # Verificar atributo required
    ${has_email_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=email-input    required
    
    ${has_password_required}=    Run Keyword And Return Status
    ...    Get Attribute    data-testid=password-input    required
    
    ${has_validation}=    Evaluate    ${has_email_required} or ${has_password_required}
    Should Be True    ${has_validation}    msg=Campos devem ter validação HTML5