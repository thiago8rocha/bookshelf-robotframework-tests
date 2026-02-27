*** Settings ***
Documentation    Testes de edição de livros

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource

Suite Setup    Ensure Default User Exists
Test Setup    Run Keywords
...    Setup UI Test
...    Login As Default User
...    Create New Book

Test Teardown    Teardown UI Test

*** Variables ***
${new_title}=    Robot Framework For Dummies
${new_author}=   Stephen King

*** Test Cases ***

User Can Edit Book Title
    [Documentation]    Valida atualização do título
    [Tags]    positive    books    ui    regression    ID=BOOKS018
    
    User Edits Book Title    ${book}[title]    ${new_title}
    Book Should Exist In List                 ${new_title}

User Can Edit Book Author
    [Documentation]    Valida atualização do autor
    [Tags]    positive    books    ui    regression    ID=BOOKS019
    
    User Edits Book Author    ${book}[title]    ${new_author}
    Book Author Should Be     ${book}[title]    ${new_author}

User Can Edit All Book Fields
    [Documentation]    Valida a edição de todos os campos de um livro
    [Tags]    positive    books    ui    regression    ID=BOOKS020
    
    ${updated_book}=    Generate New Book
    
    User Edits Complete Book    ${book}[title]    ${updated_book}
    Book Should Exist In List    ${updated_book}[title]
User Cannot Save Edited Book With Empty Title
    [Documentation]    Submeter edição com título vazio não salva — modal permanece aberto
    ...                e o título original permanece na lista
    [Tags]    negative    books    ui    validation    ID=BOOKS021
    
    Click Edit Book    ${book}[title]
    Clear Book Title
    Click    data-testid=save-book-button
    
    Wait For Elements State    data-testid=book-modal    visible    timeout=2s
    
    Click    data-testid=cancel-button
    Wait For Elements State    data-testid=book-modal    hidden
    
    Book Should Exist In List    ${book}[title]

User Cannot Save Edited Book With Empty Author
    [Documentation]    Submeter edição com autor vazio não salva — modal permanece aberto
    ...                e o livro original permanece inalterado na lista
    [Tags]    negative    books    ui    validation    ID=BOOKS022
    
    Click Edit Book    ${book}[title]
    Clear Book Author
    Click    data-testid=save-book-button
    
    Wait For Elements State    data-testid=book-modal    visible    timeout=2s
    
    Click    data-testid=cancel-button
    Wait For Elements State    data-testid=book-modal    hidden
    
    Book Should Exist In List    ${book}[title]

User Can Cancel Book Edit
    [Documentation]    Valida a possibilidade de cancelar edição
    [Tags]    negative    books    ui    ux    ID=BOOKS023
    
    Click Edit Book    ${book}[title]
    Fill Book Title    Changed Title
    Click Cancel Button
    Book Should Exist In List    ${book}[title]
    Book Should Not Exist In List    Changed Title