*** Settings ***
Documentation    Keywords de apoio para os cenários do sebo (contas, anúncios, pedidos e pagamentos simulados)

Resource    ../../../base/api.resource
Resource    ../common/data.resource

*** Keywords ***
Register User With Roles
    [Documentation]    Cria uma conta com os papéis informados e retorna token, id, email e senha
    [Arguments]    @{roles}
    ${credentials}=    Generate Unique User Credentials
    ${body}=    Create Dictionary
    ...    name=${credentials}[name]
    ...    email=${credentials}[email]
    ...    password=${credentials}[password]
    ...    roles=${roles}
    ${resp}=    POST Endpoint    /api/auth/register    ${body}
    Response Status Should Be    ${resp}    201
    ${account}=    Create Dictionary
    ...    token=${resp.json()}[token]
    ...    id=${resp.json()}[user][id]
    ...    email=${credentials}[email]
    ...    password=${credentials}[password]
    RETURN    ${account}

Create Catalog Book
    [Documentation]    Cadastra um livro na biblioteca de um leitor e devolve o id no catálogo compartilhado
    ${reader}=    Register User With Roles    reader
    ${book}=    Generate New Book
    ${resp}=    POST Authenticated    /api/books    ${book}    ${reader}[token]
    Response Status Should Be    ${resp}    201
    RETURN    ${resp.json()}[book][catalogBookId]

Create Listing For Sale
    [Documentation]    Anuncia um livro novo do catálogo como o vendedor informado
    [Arguments]    ${seller}    ${quantity}=${3}
    ${catalog_book_id}=    Create Catalog Book
    ${body}=    Create Dictionary
    ...    catalogBookId=${catalog_book_id}
    ...    priceCents=${2500}
    ...    condition=good
    ...    quantity=${quantity}
    ...    shippingFeeCents=${1200}
    ...    pickupAvailable=${True}
    ${resp}=    POST Authenticated    /api/marketplace/listings    ${body}    ${seller}[token]
    Response Status Should Be    ${resp}    201
    RETURN    ${resp.json()}[listing]

Place Pickup Order
    [Documentation]    Faz um pedido de retirada de uma unidade do anúncio
    [Arguments]    ${buyer}    ${listing_id}
    ${item}=    Create Dictionary    listingId=${listing_id}    quantity=${1}
    ${items}=    Create List    ${item}
    ${body}=    Create Dictionary    items=${items}    shippingMethod=pickup
    ${resp}=    POST Authenticated    /api/marketplace/orders    ${body}    ${buyer}[token]
    Response Status Should Be    ${resp}    201
    RETURN    ${resp.json()}[order]

Pay Order With Card
    [Documentation]    Paga o pedido com o número de cartão informado e devolve o pedido atualizado
    [Arguments]    ${buyer}    ${order_id}    ${card_number}
    ${body}=    Create Dictionary    method=card    cardNumber=${card_number}
    ${resp}=    POST Authenticated    /api/marketplace/orders/${order_id}/pay    ${body}    ${buyer}[token]
    Response Status Should Be    ${resp}    200
    RETURN    ${resp.json()}[order]
