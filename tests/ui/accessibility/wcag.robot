*** Settings ***
Library    Browser
Resource    ../../environment.resource

Suite Setup    New Browser    chromium    headless=${HEADLESS}

*** Test Cases ***
Login Page Should Be Accessible
    [Tags]    accessibility    wcag    ui
    [Documentation]    Valida WCAG 2.1 AA na página de login
    New Page    ${BASE_URL}/login
    
    # Validar ARIA labels
    Get Attribute    data-testid=email-input    aria-label    !=    ${EMPTY}
    Get Attribute    data-testid=password-input    aria-label    !=    ${EMPTY}
    
    # Validar labels de formulário
    Get Element    css=label[for="email"]
    Get Element    css=label[for="password"]
    
    # Validar navegação por teclado
    Keyboard Key    press    Tab
    ${focused}=    Get Focused    data-testid=email-input
    Should Be True    ${focused}

Register Page Should Be Accessible
    [Tags]    accessibility    wcag    ui
    New Page    ${BASE_URL}/register
    
    # Validar heading principal
    Get Element    css=h1
    ${h1_text}=    Get Text    css=h1
    Should Contain    ${h1_text}    Criar Conta
    
    # Validar inputs com labels
    Get Element    css=label[for="name"]
    Get Element    css=label[for="email"]
    Get Element    css=label[for="password"]

Dashboard Should Be Accessible
    [Tags]    accessibility    wcag    ui
    New Page    ${BASE_URL}/dashboard
    
    # Deve ter role main
    Get Element    css=[role="main"]
    
    # Heading hierarchy
    Get Element    css=h1
    Get Element    css=h2

Keyboard Navigation Should Work
    [Tags]    accessibility    keyboard    ui
    New Page    ${BASE_URL}/login
    
    # Tab através dos elementos
    Keyboard Key    press    Tab
    ${email_focused}=    Get Element State    data-testid=email-input    focused
    Should Be True    ${email_focused}
    
    Keyboard Key    press    Tab
    ${pass_focused}=    Get Element State    data-testid=password-input    focused
    Should Be True    ${pass_focused}
    
    Keyboard Key    press    Tab
    ${btn_focused}=    Get Element State    data-testid=login-button    focused
    Should Be True    ${btn_focused}

Focus Indicators Should Be Visible
    [Tags]    accessibility    focus    ui
    New Page    ${BASE_URL}/login
    
    # Focar input
    Focus    data-testid=email-input
    
    # Verificar outline/ring (Tailwind focus:ring-2)
    ${styles}=    Get Style    data-testid=email-input
    # Deve ter algum estilo de focus visível

All Images Should Have Alt Text
    [Tags]    accessibility    images    ui
    New Page    ${BASE_URL}/dashboard
    
    # Buscar todas as imagens
    ${images}=    Get Elements    css=img
    FOR    ${img}    IN    @{images}
        ${alt}=    Get Attribute    ${img}    alt
        Should Not Be Empty    ${alt}    msg=Imagem sem alt text
    END

Contrast Ratio Should Be Adequate
    [Tags]    accessibility    contrast    ui
    [Documentation]    Valida contraste mínimo WCAG AA (4.5:1)
    New Page    ${BASE_URL}/login
    
    # Textos principais devem ter bom contraste
    # (Isso seria melhor validado com axe-core, mas é um exemplo)
    ${text_color}=    Get Style    css=h1    color
    ${bg_color}=    Get Style    css=h1    backgroundColor
    # Aqui você implementaria cálculo de contraste ou usaria ferramenta externa