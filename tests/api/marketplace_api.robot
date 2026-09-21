*** Settings ***
Documentation    Testes de API do sebo: anúncios, pedidos e pagamentos simulados

Resource    ../../base/api.resource
Resource    ../../resources/helpers/common/data.resource
Resource    ../../resources/helpers/api/marketplace.resource

Suite Setup    Create API Session

*** Test Cases ***
Seller Can List A Book And Buyers Can Browse It
    [Documentation]    Um vendedor anuncia um livro do catálogo e o comprador o encontra no sebo
    [Tags]    positive    api    marketplace    ID=MKT001

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}

    ${resp}=    GET Authenticated    /api/marketplace/listings/${listing}[id]    ${buyer}[token]

    Response Status Should Be    ${resp}    200
    Should Be Equal As Integers    ${resp.json()}[listing][priceCents]    2500
    Should Be Equal    ${resp.json()}[listing][seller][id]    ${seller}[id]

Buyer Cannot Create Listings
    [Documentation]    Só quem tem o papel de vendedor pode anunciar
    [Tags]    negative    api    marketplace    security    ID=MKT002

    ${buyer}=    Register User With Roles    buyer
    ${catalog_book_id}=    Create Catalog Book
    ${body}=    Create Dictionary
    ...    catalogBookId=${catalog_book_id}
    ...    priceCents=${2500}
    ...    condition=good
    ...    quantity=${1}

    ${resp}=    POST Authenticated    /api/marketplace/listings    ${body}    ${buyer}[token]

    Response Status Should Be    ${resp}    403

Placing An Order Reserves The Stock
    [Documentation]    O pedido reserva o estoque e calcula o total com o frete fixo
    [Tags]    positive    api    marketplace    ID=MKT003

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}    ${2}

    ${order}=    Place Pickup Order    ${buyer}    ${listing}[id]

    Should Be Equal    ${order}[status]    awaiting_payment
    Should Be Equal As Integers    ${order}[totalCents]    2500
    ${after}=    GET Authenticated    /api/marketplace/listings/${listing}[id]    ${buyer}[token]
    Should Be Equal As Integers    ${after.json()}[listing][quantity]    1

Seller Cannot Buy Their Own Listing
    [Documentation]    Compra do próprio anúncio é recusada
    [Tags]    negative    api    marketplace    ID=MKT004

    ${seller}=     Register User With Roles    seller
    ${listing}=    Create Listing For Sale    ${seller}
    ${item}=       Create Dictionary    listingId=${listing}[id]    quantity=${1}
    ${items}=      Create List    ${item}
    ${body}=       Create Dictionary    items=${items}    shippingMethod=pickup

    ${resp}=    POST Authenticated    /api/marketplace/orders    ${body}    ${seller}[token]

    Response Status Should Be    ${resp}    400
    Should Be Equal    ${resp.json()}[code]    SELF_PURCHASE

Approved Test Card Marks The Order As Paid
    [Documentation]    O cartão de teste aprovado paga o pedido e só guarda bandeira e final
    [Tags]    positive    api    marketplace    payments    ID=MKT005

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]

    ${paid}=    Pay Order With Card    ${buyer}    ${order}[id]    4242 4242 4242 4242

    Should Be Equal    ${paid}[status]    paid
    Should Be Equal    ${paid}[payment][card][last4]    4242
    Should Be True    ${paid}[payment][simulated]
    ${text}=    Convert To String    ${paid}
    Should Not Contain    ${text}    4242424242424242

Declined Test Card Keeps The Order Awaiting Payment
    [Documentation]    O cartão recusado não paga o pedido e informa o motivo
    [Tags]    negative    api    marketplace    payments    ID=MKT006

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]

    ${result}=    Pay Order With Card    ${buyer}    ${order}[id]    4000 0000 0000 0002

    Should Be Equal    ${result}[status]    awaiting_payment
    Should Be Equal    ${result}[payment][failureReason]    declined

Real Card Numbers Are Refused
    [Documentation]    Um cartão que não é de teste nunca é aceito, mesmo com checksum válido
    [Tags]    negative    api    marketplace    payments    security    ID=MKT007

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]

    ${result}=    Pay Order With Card    ${buyer}    ${order}[id]    4111 1111 1111 1111

    Should Be Equal    ${result}[status]    awaiting_payment
    Should Be Equal    ${result}[payment][failureReason]    not_a_test_card

Simulated Pix Code Cannot Be Paid At A Bank
    [Documentation]    O código Pix é de teste e não segue o formato BR Code, então nenhum banco o aceita
    [Tags]    positive    api    marketplace    payments    security    ID=MKT008

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]
    ${body}=       Create Dictionary    method=pix

    ${resp}=    POST Authenticated    /api/marketplace/orders/${order}[id]/pay    ${body}    ${buyer}[token]

    Response Status Should Be    ${resp}    200
    ${code}=    Set Variable    ${resp.json()}[order][payment][pix][code]
    Should Start With    ${code}    SIMULADO-NAO-PAGUE-
    Should Not Start With    ${code}    000201
    ${lower}=    Convert To Lower Case    ${code}
    Should Not Contain    ${lower}    br.gov.bcb.pix
    Should Be Equal    ${resp.json()}[order][status]    awaiting_payment

Simulated Pix Payment Goes Through The Webhook
    [Documentation]    Simular o pagamento do Pix marca o pedido como pago
    [Tags]    positive    api    marketplace    payments    ID=MKT009

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]
    ${body}=       Create Dictionary    method=pix
    POST Authenticated    /api/marketplace/orders/${order}[id]/pay    ${body}    ${buyer}[token]

    ${empty}=    Create Dictionary
    ${resp}=     POST Authenticated    /api/marketplace/orders/${order}[id]/simulate-pix-payment    ${empty}    ${buyer}[token]

    Response Status Should Be    ${resp}    200
    Should Be Equal    ${resp.json()}[order][status]    paid

Webhook Rejects A Forged Signature
    [Documentation]    Um evento sem assinatura válida é recusado e não paga nada
    [Tags]    negative    api    marketplace    payments    security    ID=MKT010

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]
    ${body}=       Create Dictionary    method=pix
    ${pix}=        POST Authenticated    /api/marketplace/orders/${order}[id]/pay    ${body}    ${buyer}[token]
    ${event}=      Create Dictionary    chargeId=${pix.json()}[order][payment][id]    status=paid
    &{headers}=    Create Dictionary    X-Simulated-Timestamp=1800000000    X-Simulated-Signature=deadbeef

    ${resp}=    POST On Session    bookshelf_api    /api/payments/webhook    json=${event}    headers=${headers}    expected_status=any

    Response Status Should Be    ${resp}    403
    ${after}=    GET Authenticated    /api/marketplace/orders/${order}[id]    ${buyer}[token]
    Should Be Equal    ${after.json()}[order][status]    awaiting_payment

Cancelling An Unpaid Order Returns The Stock
    [Documentation]    Cancelar um pedido sem pagamento devolve o estoque ao sebo
    [Tags]    positive    api    marketplace    ID=MKT011

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}    ${1}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]
    ${empty}=      Create Dictionary

    ${resp}=    POST Authenticated    /api/marketplace/orders/${order}[id]/cancel    ${empty}    ${buyer}[token]

    Response Status Should Be    ${resp}    200
    Should Be Equal    ${resp.json()}[order][status]    cancelled
    ${after}=    GET Authenticated    /api/marketplace/listings/${listing}[id]    ${buyer}[token]
    Should Be Equal As Integers    ${after.json()}[listing][quantity]    1

Pickup Order Is Handed Over By The Seller
    [Documentation]    Em uma retirada paga, o vendedor confirma a entrega
    [Tags]    positive    api    marketplace    ID=MKT012

    ${seller}=     Register User With Roles    seller
    ${buyer}=      Register User With Roles    buyer
    ${listing}=    Create Listing For Sale    ${seller}
    ${order}=      Place Pickup Order    ${buyer}    ${listing}[id]
    Pay Order With Card    ${buyer}    ${order}[id]    4242424242424242
    ${empty}=      Create Dictionary

    ${resp}=    POST Authenticated    /api/marketplace/orders/${order}[id]/deliver    ${empty}    ${seller}[token]

    Response Status Should Be    ${resp}    200
    Should Be Equal    ${resp.json()}[order][status]    delivered

Strangers Cannot See Someone Else's Order
    [Documentation]    Só o comprador e o vendedor enxergam o pedido
    [Tags]    negative    api    marketplace    security    ID=MKT013

    ${seller}=      Register User With Roles    seller
    ${buyer}=       Register User With Roles    buyer
    ${stranger}=    Register User With Roles    buyer
    ${listing}=     Create Listing For Sale    ${seller}
    ${order}=       Place Pickup Order    ${buyer}    ${listing}[id]

    ${resp}=    GET Authenticated    /api/marketplace/orders/${order}[id]    ${stranger}[token]

    Response Status Should Be    ${resp}    404
