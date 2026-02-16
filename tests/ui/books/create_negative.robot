*** Settings ***
Resource    ../../../base/ui_base.resource
Resource    ../../../resources/flows/auth.resource
Resource    ../../../resources/flows/books.resource

Test Setup    Login As Valid User

*** Test Cases ***
User Cannot Create Book Without Title
    [Tags]    negative    books    ui
    Click Add Book Button
    Fill Book Author    Test Author
    Click Save Book
    # Validação required
    Get Attribute    id=title    required    ==    ${True}

User Cannot Create Book Without Author
    [Tags]    negative    books    ui
    Click Add Book Button
    Fill Book Title    Test Book
    Click Save Book
    # Validação required
    Get Attribute    id=author    required    ==    ${True}

User Can Cancel Book Creation
    [Tags]    negative    books    ui
    User Cancels Book Creation
    Books List Should Be Empty