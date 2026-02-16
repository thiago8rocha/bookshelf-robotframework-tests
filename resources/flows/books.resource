*** Settings ***
Resource    ../pages/books.resource

*** Keywords ***
User Creates Book
    [Arguments]    ${title}    ${author}
    Click Add Book Button
    Fill Book Title    ${title}
    Fill Book Author    ${author}
    Click Save Book
    Book Should Exist In List    ${title}

User Opens Add Book Modal
    Click Add Book Button
    Modal Should Be Visible

User Cancels Book Creation
    Click Add Book Button
    Click Cancel Button
    Modal Should Not Be Visible