# 🤖 BookShelf - Robot Framework Tests

<div align="center">
  
![Robot Framework](https://img.shields.io/badge/Robot%20Framework-7.0-000000?style=for-the-badge&logo=robot-framework&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-blue?style=for-the-badge&logo=python)
![Playwright](https://img.shields.io/badge/Playwright-2EAD33?style=for-the-badge&logo=playwright&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![CI](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

**Testes automatizados E2E e API para o sistema BookShelf**

[Instalação](#-instalação) • [Execução](#-execução) • [Estrutura](#-estrutura) • [CI/CD](#-cicd)

</div>

---

## 📋 Sobre

Suite de testes automatizados completa desenvolvida com **Robot Framework** para validação do sistema BookShelf (frontend React + backend Node.js).

### ✨ Features

- ✅ **Testes E2E (UI)** - Playwright via Browser Library
- ✅ **Testes de API** - RequestsLibrary (REST)
- ✅ **Testes de Acessibilidade** - WCAG 2.1 AA + responsividade
- ✅ **Arquitetura em camadas** - base / actions / helpers
- ✅ **CRUD Completo** - Create, Read, Update, Delete de livros
- ✅ **Geração de dados dinâmica** - FakerLibrary (pt_BR)
- ✅ **Docker Support** - Execução totalmente containerizada
- ✅ **CI/CD** - GitHub Actions com Allure Report como artefato

---

## 🛠️ Stack

| Ferramenta | Versão | Propósito |
|-----------|--------|-----------|
| [Robot Framework](https://robotframework.org/) | 7.0 | Framework de testes |
| [Browser Library](https://robotframework-browser.org/) | 18.0 | Automação web (Playwright) |
| [RequestsLibrary](https://github.com/MarketSquare/robotframework-requests) | 0.9.6 | Testes de API REST |
| [FakerLibrary](https://guykisel.github.io/robotframework-faker/) | 5.0 | Geração de dados fictícios |
| [Allure](https://docs.qameta.io/allure/) | 2.29 | Relatórios no CI |
| [Docker](https://www.docker.com/) | Latest | Containerização |
| [Python](https://www.python.org/) | 3.11 | Runtime |

---

## 🏗️ Estrutura do Projeto

```
├── .github/
│   └── workflows/
│       └── robot.yml           # Pipeline GitHub Actions
│
├── base/                       # Configuração base compartilhada
│   ├── api.resource            # Setup para testes de API
│   └── ui.resource             # Setup para testes de UI
│
├── environment.resource        # Variáveis de ambiente (URLs, credenciais)
│
├── resources/
│   ├── actions/                # Keywords de alto nível (ações do usuário)
│   │   ├── books.resource      # Operações de livros
│   │   ├── login.resource      # Operações de login/logout
│   │   └── register.resource   # Operações de registro
│   │
│   └── helpers/                # Keywords de baixo nível (técnicos)
│       ├── api/
│       │   ├── auth.resource   # Helpers de autenticação para API
│       │   └── requests.resource # Keywords HTTP genéricas (GET/POST/PUT/DELETE)
│       ├── ui/
│       │   └── browser.resource  # Helpers de browser (open, wait, etc.)
│       └── common/
│           └── data.resource   # Geração de dados e setup via API
│
├── tests/
│   ├── api/
│   │   ├── books.robot         # API: CRUD de livros + segurança (15 testes)
│   │   └── login.robot         # API: autenticação + tokens (14 testes, 1 skip)
│   │
│   └── ui/
│       ├── accessibility/
│       │   └── wcag.robot      # Acessibilidade WCAG + responsividade (18 testes)
│       ├── books/
│       │   ├── createBooks.robot  # UI: criação de livros (11 testes)
│       │   ├── editBooks.robot    # UI: edição de livros (6 testes)
│       │   └── deleteBooks.robot  # UI: exclusão de livros (6 testes)
│       └── login/
│           ├── login.robot     # UI: fluxo de login (7 testes)
│           ├── logout.robot    # UI: logout (1 teste)
│           ├── register.robot  # UI: registro de usuário (4 testes)
│           └── session.robot   # UI: persistência de sessão (4 testes)
│
├── docker-compose.ci.yml       # Ambiente completo para CI (DB + backend + frontend + robot)
├── Dockerfile                  # Imagem do container de testes
└── requirements.txt            # Dependências Python
```

**Total: 86 testes | 85 passando | 1 skipped (AUTH006 — validação de email só no frontend)**

---

## 🚀 Instalação

### Pré-requisitos

- Python 3.8+
- Node.js 18+ (para rodar a aplicação localmente)
- Docker + Docker Compose (recomendado)

### Setup local

```bash
# 1. Clone o repositório
git clone <repository-url>
cd bookshelf-robotframework-tests

# 2. Crie ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# 3. Instale dependências
pip install -r requirements.txt

# 4. Inicialize Playwright
rfbrowser init

# 5. Inicie a aplicação BookShelf (em outro terminal)
# Backend rodando em http://localhost:3000
# Frontend rodando em http://localhost:5173
```

---

## ▶️ Execução

### Via Docker (recomendado — ambiente completo e isolado)

```bash
# Sobe banco, backend, frontend e roda os testes
docker-compose -f docker-compose.ci.yml up --build --exit-code-from robot

# Para limpar tudo (volumes incluídos)
docker-compose -f docker-compose.ci.yml down -v
```

### Localmente (com aplicação rodando)

```bash
# Todos os testes
robot -d results tests/

# Por categoria
robot -d results tests/api/
robot -d results tests/ui/
robot -d results tests/ui/books/
robot -d results tests/ui/accessibility/

# Por tags
robot -d results --include smoke tests/
robot -d results --include fresh-user tests/
robot -d results --include negative tests/
robot -d results --include "api AND security" tests/

# Modo headful (ver o browser)
robot -d results -v HEADLESS:False tests/ui/
```

---

## 🏷️ Convenções de Tags

| Tag | Descrição |
|-----|-----------|
| `smoke` | Fluxos críticos — rodar sempre |
| `regression` | Cobertura completa de regressão |
| `positive` | Casos de sucesso esperado |
| `negative` | Casos de erro e validação |
| `fresh-user` | Testes que criam um usuário novo e isolado |
| `api` | Testes de API REST |
| `ui` | Testes de interface |
| `security` | Validações de autorização e autenticação |
| `accessibility` | WCAG 2.1 AA |
| `responsive` | Testes de viewport (mobile/tablet/desktop) |
| `robot:skip` | Testes pulados intencionalmente (comportamento documentado) |

---

## 📊 Relatórios

Após rodar os testes, os arquivos são gerados em `results/`:

| Arquivo | Descrição |
|---------|-----------|
| `report.html` | Resumo geral da execução |
| `log.html` | Log detalhado com screenshots de falha |
| `output.xml` | Dados estruturados para integração com CI/Allure |

```bash
# Abrir relatório no navegador (Linux/Mac)
open results/report.html

# Windows
start results/report.html
```

No CI (GitHub Actions), o **Allure Report** é gerado automaticamente e disponibilizado como artefato na run.

---

## 🎯 Mapa de IDs de Testes

| Prefixo | Escopo | Quantidade |
|---------|--------|------------|
| `BOOKS001–023` | UI: criação, edição e exclusão de livros | 23 |
| `LOGIN001–007` | UI: fluxo de login | 7 |
| `LOGOUT001` | UI: logout | 1 |
| `REGISTER001–004` | UI: registro de usuário | 4 |
| `SESSION001–004` | UI: persistência de sessão | 4 |
| `ACCESS001–012` | Acessibilidade WCAG 2.1 + teclado | 12 |
| `RESP001–006` | Responsividade (mobile/tablet/desktop) | 6 |
| `API001–015` | API: livros (CRUD + segurança) | 15 |
| `AUTH001–014` | API: autenticação e tokens | 14 |

---

## ⚙️ CI/CD

O pipeline está configurado em `.github/workflows/robot.yml` e é acionado em todo **push** ou **pull request** para a branch `main`.

### Etapas do pipeline

1. **Checkout** dos repositórios de backend, frontend e testes
2. **Build e execução** do ambiente completo via `docker-compose.ci.yml`
3. **Geração do Allure Report** (sempre, mesmo em caso de falha)
4. **Upload de artefatos** — `robot-results` (XML/HTML/screenshots) e `allure-report`

O banco de dados sobe com `tmpfs` (sem volume persistente), garantindo **isolamento total** entre execuções.

---

## 🔧 Troubleshooting

**Testes falhando com timeout**
- Verifique se backend e frontend estão saudáveis (`/health`)
- Confirme as URLs em `environment.resource`
- Em máquinas lentas, aumente os timeouts nas keywords de `browser.resource`

**Browser não abre / erro de init**
```bash
rfbrowser clean-node
rfbrowser init
```

**Erro de conexão com banco no Docker**
- Verifique se o healthcheck do container `database` passou antes do backend subir
- O `docker-compose.ci.yml` usa `depends_on: condition: service_healthy` para garantir a ordem

---

## 📚 Recursos

- [Robot Framework Docs](https://robotframework.org/robotframework/)
- [Browser Library](https://marketsquare.github.io/robotframework-browser/)
- [RequestsLibrary](https://marketsquare.github.io/robotframework-requests/)
- [FakerLibrary](https://guykisel.github.io/robotframework-faker/)
- [Allure + Robot Framework](https://allurereport.org/docs/robotframework/)