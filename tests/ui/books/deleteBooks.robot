*** Settings ***
Documentation    Testes de exclusão de livros

Resource    ../../../base/ui.resource
Resource    ../../../resources/actions/login.resource
Resource    ../../../resources/actions/books.resource

Suite Setup    Ensure Default User Exists
Test Setup       Run Keywords
...    Setup UI Test
...    Login As Default User
...    Create New Book

Test Teardown    Teardown UI Test

*** Test Cases ***

User Can Cancel Book Deletion
    [Documentation]    Valida que usuário pode cancelar exclusão
    ...                Livro deve permanecer na lista após cancelamento
    [Tags]    negative    books    ui    ux    ID=BOOKS012
    
    Click Delete Book    ${book}[title]
    Click Cancel Delete
    Book Should Exist In List    ${book}[title]

Deletion Should Require Confirmation
    [Documentation]    Valida que exclusão exige confirmação do usuário
    ...                Modal de confirmação deve aparecer
    [Tags]    negative    books    ui    ux    ID=BOOKS013
    
    Click Delete Book    ${book}[title]
    Delete Confirmation Should Be Visible
    Element Should Be Visible    text=Tem certeza

User Can Delete Book
    [Documentation]    Valida exclusão de livro único
    [Tags]    positive    books    ui    regression    ID=BOOKS014
    
    User Deletes Book    ${book}[title]
    Book Should Not Exist In List    ${book}[title]

User Can Delete Multiple Books Sequentially
    [Documentation]    Valida exclusão de vários livros em sequencia
    [Tags]    positive    books    ui    regression    ID=BOOKS015
    
    ${book1}=    Create New Book
    ${book2}=    Create New Book
    ${book3}=    Create New Book

    User Deletes Book    ${book3}
    User Deletes Book    ${book2}
    User Deletes Book    ${book1}
    
    Book Should Not Exist In List    ${book3}
    Book Should Not Exist In List    ${book2}
    Book Should Not Exist In List    ${book1}

Statistics Should Update After Deletion
    [Documentation]    Valida que estatísticas decrementam após exclusão
    [Tags]    positive    books    ui    statistics    ID=BOOKS016
    
    ${before_text}=    Get Text    data-testid=stats-total
    ${matches}=    Get Regexp Matches    ${before_text}    (\\d+)
    ${before_count}=    Set Variable    ${matches}[0]
    
    User Deletes Book    ${book}[title]
    
    ${after_text}=    Get Text    data-testid=stats-total
    ${matches}=    Get Regexp Matches    ${after_text}    (\\d+)
    ${after_count}=    Set Variable    ${matches}[0]
    
    ${before_int}=    Convert To Integer    ${before_count}
    ${after_int}=    Convert To Integer    ${after_count}
    Should Be True    ${after_int} < ${before_int}

New User Can Return To Empty State After Deleting All Books
    [Documentation]    Valida ciclo completo: vazio → com dados → vazio
    ...                Testa que usuário novo pode criar livros e deletar todos
    [Tags]    positive    books    ui    regression    fresh-user    ID=BOOKS017
    
    [Setup]    Setup UI Test
    Create Fresh User And Login
    
    # Criar 2 livros
    ${book1}=    Generate New Book
    ${book2}=    Generate New Book
    
    User Creates Book    ${book1}
    User Creates Book    ${book2}
    
    # Confirmar que existem
    Book Should Exist In List    ${book1}[title]
    Book Should Exist In List    ${book2}[title]
    
    # Deletar todos (ordem reversa - mais recente primeiro)
    User Deletes Book    ${book2}[title]
    User Deletes Book    ${book1}[title]
    
    # Validar volta ao estado vazio
    ${page_content}=    Get Text    body
    Should Contain Any    ${page_content}
    ...    Nenhum livro cadastrado
    ...    Nenhum livro ainda
    ...    biblioteca vazia
    
    ${stats_text}=    Get Text    data-testid=stats-total
    Should Contain    ${stats_text}    0