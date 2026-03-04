# BookShelf — Robot Framework Tests

<div align="center">

![Robot Framework](https://img.shields.io/badge/Robot%20Framework-7.0-000000?style=for-the-badge&logo=robot-framework&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-blue?style=for-the-badge&logo=python)
![Playwright](https://img.shields.io/badge/Playwright-2EAD33?style=for-the-badge&logo=playwright&logoColor=white)
![K6](https://img.shields.io/badge/K6-7D64FF?style=for-the-badge&logo=k6&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![CI](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Allure](https://img.shields.io/badge/Allure%20Report-GitHub%20Pages-orange?style=for-the-badge)

**Suite completa de testes automatizados para o sistema BookShelf**

[Instalação](#-instalação) • [Execução](#-execução) • [Estrutura](#-estrutura-do-projeto) • [CI/CD](#-cicd)

📊 **[Allure Report](https://thiago8rocha.github.io/bookshelf-robotframework-tests/allure-report/)**

</div>

---

## Sobre

Suite de testes automatizados desenvolvida com **Robot Framework** para validação completa do sistema BookShelf (frontend React + backend Node.js), cobrindo API, UI, acessibilidade e performance.

### Features

- ✅ **Testes de API** — RequestsLibrary (REST): autenticação, CRUD, contratos e segurança
- ✅ **Testes E2E (UI)** — Browser Library via Playwright: login, livros, dashboard, sessão
- ✅ **Testes de Acessibilidade** — WCAG 2.1 AA, navegação por teclado e responsividade
- ✅ **Testes de Performance** — K6: load, spike, soak e stress testing
- ✅ **Arquitetura em camadas** — base / actions / helpers separados por responsabilidade
- ✅ **Geração de dados dinâmica** — FakerLibrary (pt_BR)
- ✅ **Docker** — ambiente completamente containerizado via `docker-compose.yml`
- ✅ **CI/CD** — GitHub Actions com Allure Report publicado no GitHub Pages
- ✅ **Disparo manual** — execução por suite via `workflow_dispatch` no GitHub Actions

---

## Stack

| Ferramenta | Versão | Propósito |
|-----------|--------|-----------|
| [Robot Framework](https://robotframework.org/) | 7.0 | Framework de testes |
| [Browser Library](https://robotframework-browser.org/) | 18.0 | Automação web (Playwright) |
| [RequestsLibrary](https://github.com/MarketSquare/robotframework-requests) | 0.9.6 | Testes de API REST |
| [FakerLibrary](https://guykisel.github.io/robotframework-faker/) | 5.0 | Geração de dados fictícios |
| [K6](https://k6.io/) | Latest | Testes de performance |
| [Allure](https://allurereport.org/) | 3.x | Relatórios (Node.js, sem Java) |
| [Docker](https://www.docker.com/) | Latest | Containerização |
| [Python](https://www.python.org/) | 3.11 | Runtime |

---

## Estrutura do Projeto

```
├── .github/
│   └── workflows/
│       └── robot.yml               # Pipeline GitHub Actions
│
├── base/
│   ├── api.resource                # Setup base para testes de API
│   └── ui.resource                 # Setup base para testes de UI
│
├── environment.resource            # Variáveis de ambiente (URLs, credenciais)
│
├── resources/
│   ├── actions/                    # Keywords de alto nível (ações do usuário)
│   │   ├── books.resource
│   │   ├── login.resource
│   │   └── register.resource
│   │
│   └── helpers/                    # Keywords de baixo nível (técnicos)
│       ├── api/
│       │   ├── auth.resource       # Helpers de autenticação para API
│       │   └── requests.resource   # Keywords HTTP genéricas (GET/POST/PUT/DELETE)
│       ├── ui/
│       │   └── browser.resource    # Helpers de browser (open, wait, etc.)
│       ├── common/
│       │   └── data.resource       # Geração de dados e setup via API
│       └── performance/
│           ├── AllurePerformance.py # Integração Allure com métricas K6
│           └── k6.resource          # Keywords para execução dos scripts K6
│
├── tests/
│   ├── api/
│   │   ├── books_api.robot         # API: CRUD de livros + segurança (40 testes)
│   │   └── login_api.robot         # API: autenticação + tokens (20 testes)
│   │
│   ├── e2e/
│   │   └── user_journey.robot      # Jornadas completas do usuário (4 testes)
│   │
│   ├── performance/
│   │   ├── performance.robot       # Orquestrador dos testes K6 (2 testes)
│   │   └── k6/                     # Scripts K6 por cenário
│   │       ├── auth_load.js
│   │       ├── auth_spike.js
│   │       ├── auth_soak.js        # tag: slow — exclúido do CI padrão
│   │       ├── auth_stress.js      # tag: stress — excluído do CI padrão
│   │       ├── auth_performance.js
│   │       ├── books_load.js
│   │       ├── books_spike.js
│   │       ├── books_soak.js       # tag: slow — excluído do CI padrão
│   │       ├── books_stress.js     # tag: stress — excluído do CI padrão
│   │       └── books_performance.js
│   │
│   └── ui/
│       ├── accessibility/
│       │   └── wcag.robot          # WCAG 2.1 AA + teclado + responsividade (19 testes)
│       ├── books/
│       │   ├── books_create.robot  # Criação de livros (11 testes)
│       │   ├── books_edit.robot    # Edição de livros (6 testes)
│       │   ├── books_delete.robot  # Exclusão de livros (6 testes)
│       │   ├── books_modal.robot   # Modais e interações (3 testes)
│       │   └── books_status.robot  # Status e filtros de livros (7 testes)
│       ├── dashboard/
│       │   └── dashboard.robot     # Estatísticas e estado vazio (7 testes)
│       └── login/
│           ├── login.robot         # Fluxo de login (7 testes)
│           ├── logout.robot        # Logout (4 testes)
│           ├── register.robot      # Registro de usuário (4 testes)
│           └── session.robot       # Persistência de sessão (4 testes)
│
├── docker-compose.yml              # Ambiente completo (DB + backend + frontend + robot)
├── Dockerfile                      # Imagem do container de testes
├── Makefile                        # Atalhos para execução local
└── requirements.txt                # Dependências Python
```

**Total: ~164 testes de UI/API/E2E | 9 testes com `robot:skip` (comportamentos documentados) | 2 testes de performance**

---

## Instalação

### Pré-requisitos

- Docker + Docker Compose
- Repositórios `bookshelf-api` e `bookshelf-frontend` clonados na mesma pasta raiz

### Estrutura esperada de pastas

```
pasta-raiz/
├── bookshelf-robotframework-tests/   # este repositório
├── bookshelf-api/
└── bookshelf-frontend/
```

---

## Execução

### Via Makefile (recomendado)

O Makefile sobe automaticamente a aplicação se necessário e executa os testes via Docker, sem precisar instalar nada localmente.

```bash
# Suíte completa (exclui stress e slow)
make test

# Por categoria
make test-api
make test-ui
make test-e2e
make test-performance

# Por tag
make test-smoke
make test-tag T=login
make test-tag T=negative

# Arquivo específico
make test-file F=tests/ui/login/login.robot

# Infraestrutura
make up        # sobe apenas a aplicação (sem rodar testes)
make down      # derruba todos os containers
make logs      # acompanhar logs dos serviços
make build     # reconstruir a imagem do robot
make clean     # remove containers, volumes e imagens locais

# Relatório
make report    # abre results/log.html no browser
```

### Via Docker diretamente

```bash
# Sobe a aplicação
docker compose up -d --build database backend frontend

# Executa os testes
RESULTS_PATH=./results docker compose run --rm robot \
  python -m robot --exclude stress --exclude slow -d results tests/
```

### Localmente (com aplicação já rodando)

```bash
# Instale as dependências
pip install -r requirements.txt
rfbrowser init

# Execute
python -m robot -d results tests/
python -m robot -d results tests/api/
python -m robot -d results --include smoke tests/
python -m robot -d results -v HEADLESS:False tests/ui/   # modo headful
```

---

## Tags

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
| `performance` | Testes de carga e performance com K6 |
| `slow` | Soak tests (~12min) — excluídos do CI padrão |
| `stress` | Stress tests com thresholds tolerantes — excluídos do CI padrão |
| `robot:skip` | Testes pulados intencionalmente (comportamento documentado) |

---

## Relatórios

Após rodar os testes, os arquivos são gerados em `results/`:

| Arquivo | Descrição |
|---------|-----------|
| `report.html` | Resumo geral da execução |
| `log.html` | Log detalhado com screenshots de falha |
| `output.xml` | Dados estruturados para integração com Allure |

```bash
make report   # abre results/log.html no browser
```

No CI, o **Allure Report** é gerado automaticamente e publicado no GitHub Pages após cada execução na branch `main`.

📊 **[Ver Allure Report](https://thiago8rocha.github.io/bookshelf-robotframework-tests/allure-report/)**

---

## Mapa de IDs de Testes

| Prefixo | Escopo | IDs |
|---------|--------|-----|
| `API` | API: CRUD de livros + segurança | API001–040 |
| `AUTH` | API: autenticação e tokens | AUTH001–020 |
| `BOOKS` | UI: criação, edição e exclusão de livros | BOOKS001–028 |
| `BSTAT` | UI: status e filtros de livros | BSTAT001–007 |
| `DASH` | UI: dashboard e estatísticas | DASH001–007 |
| `E2E` | Jornadas completas do usuário | E2E001–004 |
| `LOGIN` | UI: fluxo de login | LOGIN001–007 |
| `LOGOUT` | UI: logout | LOGOUT001–004 |
| `REGISTER` | UI: registro de usuário | REGISTER001–004 |
| `SESSION` | UI: persistência de sessão | SESSION001–004 |
| `ACCESS` | Acessibilidade WCAG 2.1 + teclado | ACCESS001–012 |
| `RESP` | Responsividade (mobile/tablet/desktop) | RESP001–006 |

---

## CI/CD

O pipeline está configurado em `.github/workflows/robot.yml` e é acionado em:
- **Push ou Pull Request** para `main` / `master`
- **Disparo manual** via `workflow_dispatch` no GitHub Actions

### Disparo manual

Na aba **Actions** do repositório, selecione **Robot Framework Tests** → **Run workflow** e escolha a suíte:

| Opção | O que roda |
|-------|-----------|
| `all` | Tudo exceto `stress` e `slow` (padrão) |
| `all-full` | Suite completa incluindo soak e stress |
| `api` | Apenas testes de API |
| `ui` | Apenas testes de UI |
| `e2e` | Apenas jornadas E2E |
| `performance` | Performance exceto soak |
| `performance-full` | Performance completa |
| `smoke` | Apenas tag smoke |
| `regression` | Apenas tag regression |

### Etapas do pipeline

1. Checkout dos repositórios de backend, frontend e testes
2. Build e inicialização do ambiente via `docker-compose.yml`
3. Execução dos testes com geração de resultados Allure
4. Geração do Allure Report (sempre, mesmo em caso de falha)
5. Deploy automático para GitHub Pages
6. Upload de artefatos — `allure-results`, `allure-report` e `robot-html-report`
7. Criação automática de issue em caso de falha na branch principal

O banco de dados sobe com `tmpfs` (sem volume persistente), garantindo **isolamento total** entre execuções.

---

## Troubleshooting

**Testes falhando com timeout**
- Verifique se backend e frontend estão saudáveis: `docker compose ps`
- Confirme as URLs em `environment.resource`
- Em máquinas lentas, aumente os timeouts nas keywords de `browser.resource`

**Browser não abre / erro de init**
```bash
rfbrowser clean-node
rfbrowser init
```

**Containers não sobem / erro de healthcheck**
```bash
make logs       # ver o que está acontecendo
make clean      # limpar tudo e recomeçar
make up         # subir novamente
```

**Erro de path no docker-compose**
- Confirme que `bookshelf-api` e `bookshelf-frontend` estão clonados na mesma pasta raiz que este repositório

---

## Recursos

- [Robot Framework Docs](https://robotframework.org/robotframework/)
- [Browser Library](https://marketsquare.github.io/robotframework-browser/)
- [RequestsLibrary](https://marketsquare.github.io/robotframework-requests/)
- [FakerLibrary](https://guykisel.github.io/robotframework-faker/)
- [K6 Docs](https://k6.io/docs/)
- [Allure + Robot Framework](https://allurereport.org/docs/robotframework/)