*** Settings ***
Documentation    Testes de UI do sebo: compra com retirada e pagamento com cartão de teste

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/helpers/api/marketplace.resource

Suite Setup      Create API Session
Test Setup       Setup UI Test
Test Teardown    Teardown UI Test

*** Keywords ***
Log In As Buyer
    [Documentation]    Cria um comprador que também é leitor (para cair no dashboard) e entra pela tela de login
    ${buyer}=    Register User With Roles    reader    buyer
    login.Login With Credentials    ${buyer}[email]    ${buyer}[password]
    RETURN    ${buyer}

Add Listing To Cart
    [Documentation]    Procura o anúncio pelo título e o coloca no carrinho
    [Arguments]    ${listing}
    Go To    ${BASE_URL}/store
    Wait For Elements State    data-testid=store-page    visible    timeout=10s
    Fill Text    data-testid=store-search    ${listing}[book][title]
    Wait For Elements State    data-testid=listing-card-${listing}[id]    visible    timeout=10s
    Click    data-testid=add-to-cart-${listing}[id]

Check Out With Pickup
    [Documentation]    Fecha o pedido do vendedor com retirada e espera a tela do pedido
    [Arguments]    ${seller}
    Go To    ${BASE_URL}/cart
    Wait For Elements State    data-testid=cart-seller-${seller}[id]    visible    timeout=10s
    Click    data-testid=cart-method-pickup-${seller}[id]
    Click    data-testid=cart-checkout-${seller}[id]
    Wait For Elements State    data-testid=order-page    visible    timeout=10s

Pay With Card On The Order Page
    [Arguments]    ${card_number}
    Click    data-testid=payment-method-card
    Fill Text    data-testid=card-number-input    ${card_number}
    Click    data-testid=pay-card-button

*** Test Cases ***
Buyer Can Buy A Book With An Approved Test Card
    [Documentation]    Fluxo completo: vitrine, carrinho, retirada e pagamento com cartão de teste aprovado
    [Tags]    positive    store    ui    smoke    ID=STORE001

    ${seller}=     Register User With Roles    seller
    ${listing}=    Create Listing For Sale    ${seller}
    ${buyer}=      Log In As Buyer

    Add Listing To Cart    ${listing}
    Check Out With Pickup    ${seller}

    Get Text    data-testid=order-status    ==    Aguardando pagamento
    Wait For Elements State    data-testid=test-environment-banner    visible    timeout=5s
    Pay With Card On The Order Page    4242 4242 4242 4242
    Get Text    data-testid=order-status    ==    Pago

Declined Test Card Explains Why And Keeps The Order Open
    [Documentation]    O cartão de teste recusado mostra o motivo e o pedido continua aguardando pagamento
    [Tags]    negative    store    ui    ID=STORE002

    ${seller}=     Register User With Roles    seller
    ${listing}=    Create Listing For Sale    ${seller}
    ${buyer}=      Log In As Buyer

    Add Listing To Cart    ${listing}
    Check Out With Pickup    ${seller}
    Pay With Card On The Order Page    4000 0000 0000 0002

    Wait For Elements State    data-testid=payment-failure    visible    timeout=10s
    Get Text    data-testid=payment-failure    contains    recusado
    Get Text    data-testid=order-status    ==    Aguardando pagamento

Real Card Is Refused On The Payment Screen
    [Documentation]    Um cartão que não é de teste é recusado com aviso claro
    [Tags]    negative    store    ui    security    ID=STORE003

    ${seller}=     Register User With Roles    seller
    ${listing}=    Create Listing For Sale    ${seller}
    ${buyer}=      Log In As Buyer

    Add Listing To Cart    ${listing}
    Check Out With Pickup    ${seller}
    Pay With Card On The Order Page    4111 1111 1111 1111

    Wait For Elements State    data-testid=payment-failure    visible    timeout=10s
    Get Text    data-testid=payment-failure    contains    reais
    Get Text    data-testid=order-status    ==    Aguardando pagamento

Simulated Pix Is Clearly Marked As Not Payable
    [Documentation]    O Pix gerado exibe o código de teste e o aviso de que não pode ser pago no banco
    [Tags]    positive    store    ui    security    ID=STORE004

    ${seller}=     Register User With Roles    seller
    ${listing}=    Create Listing For Sale    ${seller}
    ${buyer}=      Log In As Buyer

    Add Listing To Cart    ${listing}
    Check Out With Pickup    ${seller}
    Click    data-testid=generate-pix-button

    Wait For Elements State    data-testid=pix-code    visible    timeout=10s
    Get Text    data-testid=pix-code    contains    SIMULADO-NAO-PAGUE-
    Get Text    data-testid=payment-panel    contains    não pode ser pago no seu banco
    Click    data-testid=simulate-pix-button
    Get Text    data-testid=order-status    ==    Pago
