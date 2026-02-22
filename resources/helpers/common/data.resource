*** Settings ***
Documentation    Keywords de geração de dados dinâmicos

Resource   ../../../base/ui.resource

*** Keywords ***

Generate Random Email
    [Documentation]    Gera email único
    ${timestamp}=    Get Time    epoch
    ${random}=    Evaluate    random.randint(100000, 999999)    modules=random
    ${email}=    Set Variable    test${timestamp}${random}@test.com
    RETURN    ${email}

Generate New Book
    [Documentation]    Gera um livro com todos os dados aleatorios

    # Title
    ${title_size}=    FakerLibrary.Random Int    min=1    max=5
    ${words}=           FakerLibrary.Words         nb=${title_size}
    ${title_raw}=       Evaluate    " ".join($words).title()
    ${title}=           Replace String    ${title_raw}    .    ${EMPTY}

    # Year
    ${current_year}=       Get Current Date    result_format=%Y
    ${publishedYear}=   FakerLibrary.Random Int    min=1900    max=${current_year}
    
    # ISBN
    ${isbn_raw}=            FakerLibrary.Isbn13
    ${isbn}=            Replace String    ${isbn_raw}    -    ${EMPTY}
    
    ${author}=          FakerLibrary.Name
    ${publisher}=       FakerLibrary.Company
    ${pages}=           FakerLibrary.Random Int    min=50    max=1200
    ${language}=        Set Variable    Portuguese
    ${description}=     FakerLibrary.Text    max_nb_chars=500

    ${Book}=     Create Dictionary    
    ...    title=${title}    
    ...    author=${author}    
    ...    isbn=${isbn}    
    ...    publisher=${publisher}    
    ...    publishedYear=${publishedYear}    
    ...    pages=${pages}    
    ...    language=${language}    
    ...    description=${description}

    RETURN    ${Book}