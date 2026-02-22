# 🤖 BookShelf - Robot Framework Tests

<div align="center">
  
![Robot Framework](https://img.shields.io/badge/Robot%20Framework-000000?style=for-the-badge&logo=robot-framework&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-blue?style=for-the-badge&logo=python)
![Playwright](https://img.shields.io/badge/Playwright-2EAD33?style=for-the-badge&logo=playwright&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

**Testes automatizados E2E e API para o sistema BookShelf**

[Instalação](#-instalação) • [Execução](#-execução) • [Estrutura](#-estrutura) • [CI/CD](#-cicd)

</div>

---

## 📋 Sobre

Suite de testes automatizados completa desenvolvida com **Robot Framework** para validação do sistema BookShelf (frontend React + backend Node.js).

### ✨ Features

- ✅ **Testes E2E (UI)** - Playwright/Browser Library
- ✅ **Testes de API** - RequestsLibrary
- ✅ **Testes de Acessibilidade** - WCAG 2.1 AA
- ✅ **Page Object Model** - Arquitetura escalável
- ✅ **CRUD Completo** - Create, Read, Update, Delete
- ✅ **Parallel Execution** - Pabot (4 processos)
- ✅ **Custom Reports** - HTML customizado + Allure
- ✅ **Data-driven Tests** - Templates e fixtures JSON
- ✅ **Docker Support** - Execução containerizada
- ✅ **CI/CD Ready** - GitHub Actions configurado

---

## 🛠️ Stack

| Ferramenta | Versão | Propósito |
|-----------|--------|-----------|
| [Robot Framework](https://robotframework.org/) | 7.0 | Framework de testes |
| [Browser Library](https://robotframework-browser.org/) | 18.0 | Automação web (Playwright) |
| [RequestsLibrary](https://github.com/MarketSquare/robotframework-requests) | 0.9.6 | Testes de API |
| [Pabot](https://pabot.org/) | 2.18 | Execução paralela |
| [Allure](https://docs.qameta.io/allure/) | 2.13 | Relatórios |
| [Docker](https://www.docker.com/) | Latest | Containerização |
| [Python](https://www.python.org/) | 3.11 | Runtime |

---

## 🏗️ Estrutura do Projeto

```
├── base/                       # Configuração base para UI e API
│   ├── api.resource           # Setup para testes de API
│   └── ui.resource            # Setup para testes de UI
│
├── environment.resource       # Variáveis de ambiente (URLs, credenciais)
│
├── resources/
│   ├── actions/              # Keywords de alto nível (user actions)
│   │   ├── books.resource    # Operações de livros
│   │   ├── login.resource    # Operações de login
│   │   └── register.resource # Operações de registro
│   │
│   └── helpers/              # Keywords de baixo nível (helpers técnicos)
│       ├── api/              # Helpers para API
│       ├── ui/               # Helpers para UI
│       └── common/           # Helpers compartilhados (geração de dados)
│
└── tests/
    ├── api/                  # Testes de API REST
    │   ├── books.robot
    │   └── login.robot
    │
    └── ui/                   # Testes de interface
        ├── accessibility/
        ├── books/
        └── login/
```

## 🚀 Instalação

### Pré-requisitos

- Python 3.8+
- Node.js 16+ (para rodar aplicação)
- npm ou yarn

### Setup

```bash
# 1. Clone o repositório
git clone <repository-url>
cd bookshelf-tests

# 2. Crie ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# 3. Instale dependências
pip install robotframework
pip install robotframework-browser
pip install robotframework-requests
pip install robotframework-faker

# 4. Inicialize Playwright
rfbrowser init

# 5. Inicie a aplicação (em outro terminal)
cd ../bookshelf-app
npm install
npm run dev    # Frontend rodando em http://localhost:5173
npm run api    # Backend rodando em http://localhost:3000
```

## ▶️ Executando os Testes

### Todos os testes

```bash
robot tests/
```

### Por categoria

```bash
# Apenas API
robot tests/api/

# Apenas UI
robot tests/ui/

# Apenas livros
robot tests/ui/books/

# Apenas acessibilidade
robot tests/ui/accessibility/
```

### Por tags

```bash
# Apenas smoke tests
robot --include smoke tests/

# Apenas testes com usuários novos
robot --include fresh-user tests/

# Apenas testes negativos
robot --include negative tests/

# Excluir testes longos
robot --exclude slow tests/
```

### Modo headful (ver browser)

```bash
# Editar environment.resource
${HEADLESS}    False

# Ou via command line
robot -v HEADLESS:False tests/ui/
```

## 🏷️ Convenções de Tags

- `smoke` - Testes críticos de fluxo principal
- `regression` - Testes de regressão completa
- `positive` - Casos de sucesso
- `negative` - Casos de erro
- `fresh-user` - Testes que criam novo usuário
- `api` - Testes de API
- `ui` - Testes de interface
- `books` - Relacionado a livros
- `login` - Relacionado a autenticação

## 📊 Relatórios

Após executar os testes, arquivos são gerados:

- `log.html` - Log detalhado com screenshots de falhas
- `report.html` - Relatório resumido
- `output.xml` - Dados estruturados (para CI/CD)

Abrir no navegador:

```bash
# Linux/Mac
open report.html

# Windows
start report.html
```

## 🔧 Troubleshooting

### Testes falhando com timeout

- Verifique se aplicação está rodando
- Confirme URLs corretas em `environment.resource`
- Aumente timeout em caso de máquina lenta

### Browser não abre

```bash
# Reinicialize Playwright
rfbrowser clean-node
rfbrowser init
```

## 🎯 IDs de Testes

| Categoria | Range | Exemplo |
|-----------|-------|---------|
| Books Create | BOOKS001-010 | BOOKS001 |
| Books Edit | BOOKS011-020 | BOOKS011 |
| Books Delete | BOOKS021-030 | BOOKS021 |
| Login | LOGIN001-010 | LOGIN001 |
| Register | REG001-010 | REG001 |
| Accessibility | A11Y001-100 | A11Y001 |

## 📚 Recursos

- [Robot Framework Docs](https://robotframework.org/robotframework/)
- [Browser Library](https://marketsquare.github.io/robotframework-browser/)
- [RequestsLibrary](https://marketsquare.github.io/robotframework-requests/)
- [FakerLibrary](https://guykisel.github.io/robotframework-faker/)