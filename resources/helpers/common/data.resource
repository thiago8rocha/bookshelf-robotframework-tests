*** Settings ***
Documentation    Geração de dados e criação de usuários/livros para testes

Library    DateTime
Library    String
Library    Collections
Library    RequestsLibrary
Library    FakerLibrary    locale=pt_BR

Resource    ../../../environment.resource

*** Keywords ***

# =============================================================================
# DATA GENERATION
# =============================================================================

Generate Random Email
    [Documentation]    Gera email único com timestamp e random
    ${timestamp}=    Get Time    epoch
    ${random}=       Evaluate    random.randint(100000, 999999)
    ${email}=        Set Variable    test${timestamp}${random}@test.com
    RETURN    ${email}

Generate Unique User Credentials
    [Documentation]    Gera credenciais únicas para um novo usuário
    ...                Retorna dicionário com name, email, password
    
    ${name}=     FakerLibrary.Name
    ${email}=    Generate Random Email
    ${password}=    Set Variable    Test@123456
    
    ${credentials}=    Create Dictionary
    ...                name=${name}
    ...                email=${email}
    ...                password=${password}
    
    RETURN    ${credentials}

Generate New Book
    [Documentation]    Gera um livro com todos os dados aleatórios
    ...                Inclui validação de campos obrigatórios e opcionais
    
    ${timestamp}=    Get Time    epoch
    
    ${title}=       FakerLibrary.Sentence    nb_words=4
    ${title}=       Set Variable    ${title} ${timestamp}
    ${author}=      FakerLibrary.Name
    ${isbn}=        FakerLibrary.Isbn13
    ${publisher}=   FakerLibrary.Company
    ${year}=        Evaluate    random.randint(1900, 2024)
    ${pages}=       Evaluate    random.randint(50, 1200)
    ${description}=    FakerLibrary.Text    max_nb_chars=500
    
    ${book}=    Create Dictionary
    ...         title=${title}
    ...         author=${author}
    ...         isbn=${isbn}
    ...         publisher=${publisher}
    ...         publishedYear=${year}
    ...         pages=${pages}
    ...         language=Portuguese
    ...         description=${description}
    
    RETURN    ${book}

Generate Book With Required Fields Only
    [Documentation]    Gera livro apenas com campos obrigatórios
    
    ${timestamp}=    Get Time    epoch
    
    ${title}=    FakerLibrary.Sentence    nb_words=3
    ${title}=    Set Variable    ${title} ${timestamp}
    ${author}=   FakerLibrary.Name
    
    ${book}=    Create Dictionary
    ...         title=${title}
    ...         author=${author}
    
    RETURN    ${book}

# =============================================================================
# API HELPERS - USER CREATION
# =============================================================================

Create User Via API
    [Documentation]    Cria usuário via API
    ...                Retorna response completo da API
    [Arguments]    ${credentials}
    
    Create Session    api_setup    ${API_URL}    verify=${False}
    
    ${body}=    Create Dictionary
    ...         name=${credentials}[name]
    ...         email=${credentials}[email]
    ...         password=${credentials}[password]
    
    ${resp}=    POST On Session    api_setup
    ...         /api/auth/register
    ...         json=${body}
    ...         expected_status=any
    
    RETURN    ${resp}

Login Via API
    [Documentation]    Faz login via API e retorna token
    [Arguments]    ${email}    ${password}
    
    Create Session    api_login    ${API_URL}    verify=${False}
    
    ${body}=    Create Dictionary
    ...         email=${email}
    ...         password=${password}
    
    ${resp}=    POST On Session    api_login
    ...         /api/auth/login
    ...         json=${body}
    ...         expected_status=any
    
    Should Be Equal As Integers    ${resp.status_code}    200
    RETURN    ${resp.json()}[token]

# =============================================================================
# USER CREATION - SEPARADO DO LOGIN
# =============================================================================

Create Fresh User
    [Documentation]    Cria um NOVO usuário via UI
    ...                Apenas registra, NÃO faz login
    ...                Retorna as credenciais criadas
    ...
    ...                Uso:
    ...                ${user}=    Create Fresh User
    ...                Log    Usuário criado: ${user}[email]
    
    ${credentials}=    Generate Unique User Credentials
    
    Go To    ${BASE_URL}/register
    Wait For Elements State    data-testid=register-page    visible    timeout=10s
    
    Wait For Elements State    data-testid=name-input    visible    timeout=5s
    Wait For Elements State    data-testid=email-input    visible    timeout=5s
    Wait For Elements State    data-testid=password-input    visible    timeout=5s
    
    Fill Text    data-testid=name-input       ${credentials}[name]
    Fill Text    data-testid=email-input      ${credentials}[email]
    Fill Text    data-testid=password-input   ${credentials}[password]
    
    Wait For Elements State    data-testid=register-button    enabled    timeout=5s
    Click    data-testid=register-button
    
    Wait For Elements State    data-testid=dashboard-page    visible    timeout=15s
    
    RETURN    ${credentials}

Create Fresh User And Login
    [Documentation]    Cria usuário E faz login
    ...                Retorna credenciais completas
    ...                Usuário fica logado no browser
    
    ${credentials}=    Create Fresh User
    RETURN    ${credentials}

# =============================================================================
# MASS DATA CREATION
# =============================================================================

Create User With Books
    [Documentation]    Cria usuário com N livros via API
    ...                Útil para setup de testes que precisam de dados
    ...                Retorna (user_dict, list_of_books)
    [Arguments]    ${book_count}=2
    
    ${credentials}=    Generate Unique User Credentials
    
    # Criar usuário
    ${register_resp}=    Create User Via API    ${credentials}
    Should Be Equal As Integers    ${register_resp.status_code}    201
    
    # Fazer login para obter token
    ${token}=    Login Via API    ${credentials}[email]    ${credentials}[password]
    
    # Criar livros
    @{books_created}=    Create List
    FOR    ${i}    IN RANGE    ${book_count}
        ${book}=    Generate New Book
        ${created_book}=    Create Book Via API    ${book}    ${token}
        Append To List    ${books_created}    ${created_book}
    END
    
    # Adicionar token ao dict do usuário
    Set To Dictionary    ${credentials}    token    ${token}
    
    RETURN    ${credentials}    ${books_created}

Create Book Via API
    [Documentation]    Cria livro via API
    ...                Retorna livro criado com ID
    [Arguments]    ${book}    ${token}
    
    Create Session    api_setup    ${API_URL}    verify=${False}
    
    ${headers}=    Create Dictionary
    ...            Authorization=Bearer ${token}
    ...            Content-Type=application/json
    
    ${resp}=    POST On Session    api_setup
    ...         /api/books
    ...         json=${book}
    ...         headers=${headers}
    ...         expected_status=any
    
    Should Be Equal As Integers    ${resp.status_code}    201
    
    RETURN    ${resp.json()}[book]

# =============================================================================
# CLEANUP HELPERS
# =============================================================================

Delete All User Books Via API
    [Documentation]    Deleta todos os livros de um usuário via API
    ...                Útil para teardown de testes
    [Arguments]    ${token}
    
    Create Session    api_cleanup    ${API_URL}    verify=${False}
    
    ${headers}=    Create Dictionary
    ...            Authorization=Bearer ${token}
    
    # Listar todos os livros
    ${resp}=    GET On Session    api_cleanup
    ...         /api/books
    ...         headers=${headers}
    ...         expected_status=any
    
    Return From Keyword If    ${resp.status_code} != 200
    
    ${books}=    Set Variable    ${resp.json()}[books]
    ${book_count}=    Get Length    ${books}
    
    # Deletar cada livro
    FOR    ${book}    IN    @{books}
        ${book_id}=    Set Variable    ${book}[id]
        DELETE On Session    api_cleanup
        ...    /api/books/${book_id}
        ...    headers=${headers}
        ...    expected_status=any
    END
    
    Log    Deletados ${book_count} livros do usuário