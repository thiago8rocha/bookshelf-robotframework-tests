*** Variables ***
# ==========================================
# URLS
# ==========================================
${BASE_URL}         http://localhost:5173
${API_URL}          http://localhost:3000

# ==========================================
# BROWSER
# ==========================================
${BROWSER}          chromium
${HEADLESS}         True              
${TIMEOUT}          10s

# ==========================================
# TEST DATA
# ==========================================
${USER_EMAIL}       test@email.com
${USER_PASS}        123456
${TEST_USER_PASS}   test123456

# ==========================================
# API
# ==========================================
${API_SESSION}      bookshelf_api

# ==========================================
# SUITE VARIABLES (inicializadas vazias)
# ==========================================
${AUTH_TOKEN}       ${EMPTY}
${TEST_USER_EMAIL}  ${EMPTY}
${CREATED_BOOK_ID}  ${EMPTY}
${TEST_BOOK_TITLE}  ${EMPTY}