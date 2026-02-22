*** Settings ***
Documentation    Actions para gerenciamento de livros

Resource    ../../base/ui.resource

*** Keywords ***
User Creates Book
    [Documentation]    Usuario cria um livro com os campos obrigatórios preenchidos
    [Arguments]    ${book}
    Click Add Book Button    
    Fill Text    id=title    ${book.title}
    Fill Text    id=author    ${book.author}
    Click Save Book Button

    RETURN    ${book.title}    ${book.author}

User Creates Complete Book
    [Documentation]    Usuario cria um livro com todos os campos preenchidos
    [Arguments]    ${book}
    Click Add Book Button
    Fill Text    id=title    ${book.title}
    Fill Text    id=author    ${book.author}
    Fill Text    id=isbn    ${book.isbn}
    Fill Text    id=publisher    ${book.publisher}
    Fill Text    id=publishedYear    ${book.publishedYear}
    Fill Text    id=pages    ${book.pages}
    Fill Text    id=language    ${book.language}
    Fill Text    id=description    ${book.description}
    Click Save Book Button

Create New Book
    ${book}=    Generate New Book
    User Creates Book    ${book}  
    Book Should Exist In List    ${book.title}
    Set Test Variable    ${book}
    RETURN    ${book.title}

User Edits Book Title
    [Arguments]    ${old_title}    ${new_title}
    Click Edit Book    ${old_title}
    Clear Text    id=title
    Fill Text    id=title    ${new_title}
    Click Save Book Button

User Edits Book Author
    [Arguments]    ${title}    ${new_author}
    Click Edit Book    ${title}
    Clear Text    id=author
    Fill Text    id=author    ${new_author}
    Click Save Book Button

User Edits Complete Book
    [Documentation]    Edita livro com todos os campos
    [Arguments]    ${old_title}    ${updated_book}
    Click Edit Book    ${old_title}
    Clear Text    id=title
    Fill Text    id=title    ${updated_book['title']}
    Clear Text    id=author
    Fill Text    id=author    ${updated_book['author']}
    Fill Text    id=isbn    ${updated_book['isbn']}
    Fill Text    id=publisher    ${updated_book['publisher']}
    Fill Text    id=publishedYear    ${updated_book['publishedYear']}
    Fill Text    id=pages    ${updated_book['pages']}
    Fill Text    id=language    ${updated_book['language']}
    Fill Text    id=description    ${updated_book['description']}
    Click Save Book Button

User Deletes Book
    [Arguments]    ${title}
    Click Delete Book    ${title}
    Click    data-testid=confirm-delete-button
    Wait For Elements State    data-testid=delete-confirm-modal    hidden    timeout=5s
    Sleep    2s

Fill Book Title
    [Arguments]    ${title}
    Wait For Elements State    id=title    visible
    Fill Text    id=title    ${title}

Fill Book Author
    [Arguments]    ${author}
    Wait For Elements State    id=author    visible
    Fill Text    id=author    ${author}

Clear Book Title
    Wait For Elements State    id=title    visible
    Clear Text    id=title

Clear Book Author
    Wait For Elements State    id=author    visible
    Clear Text    id=author

Click Add Book Button
    Click    data-testid=add-book-button
    Wait For Elements State    data-testid=book-modal    visible

Click Save Book Button
    Click    data-testid=save-book-button
    Wait For Elements State    data-testid=book-modal    hidden    timeout=8s

Click Cancel Button
    Wait For Elements State    data-testid=cancel-button    visible
    Click    data-testid=cancel-button

Click Edit Book
    [Arguments]    ${title}
    Wait For Elements State    css=[data-testid^="book-item-"]    attached    timeout=2s
    ${books}=    Get Elements    css=[data-testid^="book-item-"]
    FOR    ${book}    IN    @{books}
        ${book_text}=    Get Text    ${book}
        ${title_lines}=    Split String    ${book_text}    \n
        ${book_title}=    Set Variable    ${title_lines}[0]
        ${has_title}=    Run Keyword And Return Status
        ...    Should Be Equal    ${book_title}    ${title}
        IF    ${has_title}
            ${edit_btn}=    Get Element    ${book} >> css=[data-testid^="edit-book-"]
            Click    ${edit_btn}
            Wait For Elements State    data-testid=book-modal    visible
            RETURN
        END
    END
    Fail    Livro "${title}" não encontrado

Click Delete Book
    [Arguments]    ${title}
    Wait For Elements State    css=[data-testid^="book-item-"]    attached    timeout=2s
    ${books}=    Get Elements    css=[data-testid^="book-item-"]
    FOR    ${book}    IN    @{books}
        ${book_text}=    Get Text    ${book}
        ${title_lines}=    Split String    ${book_text}    \n
        ${book_title}=    Set Variable    ${title_lines}[0]
        ${has_title}=    Run Keyword And Return Status
        ...    Should Be Equal    ${book_title}    ${title}
        IF    ${has_title}
            ${del_btn}=    Get Element    ${book} >> css=[data-testid^="delete-book-"]
            Click    ${del_btn}
            Wait For Elements State    data-testid=delete-confirm-modal    visible
            RETURN
        END
    END
    Fail    Livro "${title}" não encontrado

Click Confirm Delete
    Wait For Elements State    data-testid=confirm-delete-button    visible
    Click    data-testid=confirm-delete-button
    Wait For Elements State    data-testid=delete-confirm-modal    hidden    timeout=5s
    Sleep    2s

Click Cancel Delete
    Wait For Elements State    data-testid=cancel-delete-button    visible
    Click    data-testid=cancel-delete-button

Delete Confirmation Should Be Visible
    Wait For Elements State    data-testid=delete-confirm-modal    visible

Modal Should Be Visible
    Wait For Elements State    data-testid=book-modal    visible

Modal Should Not Be Visible
    Wait For Elements State    data-testid=book-modal    hidden

Book Should Exist In List
    [Arguments]    ${title}
    Wait For Elements State    body    stable    timeout=2s
    ${page_content}=    Get Text    body
    Should Contain    ${page_content}    ${title}

Book Should Not Exist In List
    [Arguments]    ${title}
    Wait For Elements State    body    stable    timeout=2s
    ${page_content}=    Get Text    body
    Should Not Contain    ${page_content}    ${title}

Books List Should Be Empty
    Wait For Elements State    body    stable    timeout=2s
    ${page_content}=    Get Text    body
    Should Contain Any    ${page_content}    Nenhum livro ainda    vazia

Book Author Should Be
    [Arguments]    ${title}    ${expected_author}
    ${books}=    Get Elements    css=[data-testid^="book-item-"]
    FOR    ${book}    IN    @{books}
        ${book_text}=    Get Text    ${book}
        ${title_lines}=    Split String    ${book_text}    \n
        ${book_title}=    Set Variable    ${title_lines}[0]
        ${has_title}=    Run Keyword And Return Status
        ...    Should Be Equal    ${book_title}    ${title}
        IF    ${has_title}
            Should Contain    ${book_text}    ${expected_author}
            RETURN
        END
    END
    Fail    Livro "${title}" não encontrado