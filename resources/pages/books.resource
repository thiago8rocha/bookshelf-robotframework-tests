*** Settings ***
Library    Browser

*** Keywords ***
Click Add Book Button
    Wait For Elements State    data-testid=add-book-button    visible
    Click    data-testid=add-book-button

Fill Book Title
    [Arguments]    ${title}
    Wait For Elements State    id=title    visible
    Fill Text    id=title    ${title}

Fill Book Author
    [Arguments]    ${author}
    Wait For Elements State    id=author    visible
    Fill Text    id=author    ${author}

Fill Book ISBN
    [Arguments]    ${isbn}
    Fill Text    id=isbn    ${isbn}

Fill Book Publisher
    [Arguments]    ${publisher}
    Fill Text    id=publisher    ${publisher}

Fill Book Year
    [Arguments]    ${year}
    Fill Text    id=publishedYear    ${year}

Fill Book Pages
    [Arguments]    ${pages}
    Fill Text    id=pages    ${pages}

Fill Book Language
    [Arguments]    ${language}
    Fill Text    id=language    ${language}

Fill Book Description
    [Arguments]    ${description}
    Fill Text    id=description    ${description}

Click Save Book
    Click    text=Adicionar Livro

Click Cancel Button
    Click    text=Cancelar

Modal Should Be Visible
    Wait For Elements State    text=Adicionar Livro    visible

Modal Should Not Be Visible
    Wait For Elements State    text=Adicionar Livro    hidden

Book Should Exist In List
    [Arguments]    ${title}
    Wait For Elements State    text=${title}    visible    timeout=5s

Books List Should Be Empty
    Wait For Elements State    text=Nenhum livro ainda    visible