*** Settings ***
Documentation    Testes de comportamento do modal de livros
...
...              Valida o BookModal: abertura em modo adicionar/editar,
...              fechamento pelo botão X e exibição de erros de API.

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource
Resource    ../../../resources/helpers/common/data.resource

Suite Setup    Ensure Default User Exists
Test Setup     Run Keywords
...    Setup UI Test
...    Login As Default User
Test Teardown    Teardown UI Test

*** Test Cases ***

Add Book Modal Opens With Correct Title
    [Documentation]    Ao clicar em "Adicionar Livro" o modal abre com o título
    ...                "Adicionar Livro" — não "Editar Livro"
    [Tags]    positive    books    ui    modal    ID=BOOKS026

    Click Add Book Button

    ${modal_text}=    Get Text    data-testid=book-modal
    Should Contain    ${modal_text}    Adicionar Livro
    Should Not Contain    ${modal_text}    Editar Livro

    Click    data-testid=modal-close-button
    Wait For Elements State    data-testid=book-modal    hidden

Modal Close Button Closes Modal Without Saving
    [Documentation]    O botão X (modal-close-button) fecha o modal sem salvar o livro
    ...                O título preenchido não deve aparecer na lista após fechar
    [Tags]    positive    books    ui    modal    ux    ID=BOOKS027

    Click Add Book Button

    Fill Text    id=title     Livro Que Nao Deve Ser Salvo
    Fill Text    id=author    Autor Fantasma

    Click    data-testid=modal-close-button
    Wait For Elements State    data-testid=book-modal    hidden

    Book Should Not Exist In List    Livro Que Nao Deve Ser Salvo

Edit Book Modal Opens With Correct Title And Prepopulated Fields
    [Documentation]    Ao editar um livro, o modal abre com título "Editar Livro"
    ...                e os campos title/author já preenchidos com os dados atuais
    [Tags]    positive    books    ui    modal    ID=BOOKS028

    # Criar livro para ter algo para editar
    ${book}=    Generate Book With Required Fields Only
    User Creates Book    ${book}

    Click Edit Book    ${book}[title]

    ${modal_text}=    Get Text    data-testid=book-modal
    Should Contain    ${modal_text}    Editar Livro
    Should Not Contain    ${modal_text}    Adicionar Livro

    ${title_value}=    Get Property    id=title     value
    ${author_value}=   Get Property    id=author    value

    Should Be Equal    ${title_value}     ${book}[title]
    Should Be Equal    ${author_value}    ${book}[author]

    Click    data-testid=modal-close-button
    Wait For Elements State    data-testid=book-modal    hidden
