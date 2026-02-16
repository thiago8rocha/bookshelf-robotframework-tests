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
- ✅ **Docker Support** - Execução containerizada
- ✅ **CI/CD Ready** - GitHub Actions configurado
- ✅ **Allure Reports** - Relatórios detalhados
- ✅ **Data-driven Tests** - Fixtures JSON
- ✅ **Parallel Execution** - Múltiplos workers

---

## 🛠️ Stack

| Ferramenta | Versão | Propósito |
|-----------|--------|-----------|
| [Robot Framework](https://robotframework.org/) | Latest | Framework de testes |
| [Browser Library](https://robotframework-browser.org/) | Latest | Automação web (Playwright) |
| [RequestsLibrary](https://github.com/MarketSquare/robotframework-requests) | Latest | Testes de API |
| [Allure](https://docs.qameta.io/allure/) | Latest | Relatórios |
| [Docker](https://www.docker.com/) | Latest | Containerização |
| [Python](https://www.python.org/) | 3.11 | Runtime |

---

## 📂 Estrutura do Projeto
```
bookshelf-robot-tests/
├── .github/
│   └── workflows/
│       └── robot.yml              # GitHub Actions CI/CD
│
├── base/
│   ├── api_base.resource          # Setup base para testes API
│   └── ui_base.resource           # Setup base para testes UI
│
├── resources/
│   ├── fixtures/                  # Dados de teste
│   │   ├── users.json
│   │   └── books.json
│   │
│   ├── flows/                     # Fluxos de negócio (high-level)
│   │   ├── auth.resource
│   │   └── books.resource
│   │
│   ├── helpers/                   # Utilitários reutilizáveis
│   │   ├── api.resource
│   │   ├── browser.resource
│   │   ├── ui.resource
│   │   └── data.resource
│   │
│   └── pages/                     # Page Objects (low-level)
│       ├── login.resource
│       ├── register.resource
│       ├── dashboard.resource
│       └── books.resource
│
├── tests/
│   ├── api/                       # Testes de API
│   │   ├── auth.robot
│   │   └── books.robot
│   │
│   ├── ui/                        # Testes de interface
│   │   ├── auth/
│   │   │   ├── login.robot
│   │   │   ├── logout.robot
│   │   │   └── register.robot
│   │   └── books/
│   │       ├── create.robot
│   │       ├── list.robot
│   │       ├── edit.robot
│   │       └── delete.robot
│   │
│   └── accessibility/             # Testes de acessibilidade
│       └── wcag.robot
│
├── results/                       # Relatórios (gerado)
├── environment.resource           # Variáveis de ambiente
├── requirements.txt               # Dependências Python
├── Dockerfile                     # Imagem Docker
├── docker-compose.yml             # Orquestração
└── README.md                      # Este arquivo
```

---

## 🚀 Instalação

### Pré-requisitos

- Python 3.11+
- Node.js 18+ (para o projeto principal)
- Docker (opcional, mas recomendado)

### Opção 1: Local (Python)
```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/bookshelf-robot-tests.git
cd bookshelf-robot-tests

# 2. Crie um ambiente virtual
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate

# 3. Instale as dependências
pip install -r requirements.txt

# 4. Inicialize o Browser Library (Playwright)
rfbrowser init
```

### Opção 2: Docker (Recomendado)
```bash
# Build da imagem
docker-compose build

# Pronto! Não precisa instalar nada localmente
```

---

## ▶️ Execução

### Pré-requisitos de Execução

**IMPORTANTE:** Os testes assumem que você tem:

1. ✅ **Backend** rodando em `http://localhost:3000`
2. ✅ **Frontend** rodando em `http://localhost:5173`
```bash
# Terminal 1 - Backend
cd bookshelf-api
docker-compose up

# Terminal 2 - Frontend
cd bookshelf-frontend
npm run dev

# Terminal 3 - Testes
cd bookshelf-robot-tests
# ... comandos abaixo
```

---

### Local
```bash
# Todos os testes
robot -d results tests/

# Apenas testes de UI
robot -d results tests/ui/

# Apenas testes de API
robot -d results tests/api/

# Apenas testes de acessibilidade
robot -d results tests/accessibility/

# Por tag
robot -d results -i smoke tests/
robot -d results -i "auth AND ui" tests/

# Com relatório Allure
robot -d results --listener allure_robotframework tests/
```

### Docker
```bash
# Todos os testes
docker-compose run robot

# Testes específicos
docker-compose run robot robot -d results tests/ui/

# Com relatório Allure
docker-compose run robot robot -d results --listener allure_robotframework tests/
```

### CI/CD (GitHub Actions)
```bash
# Executado automaticamente em push/PR para main
# Veja o arquivo .github/workflows/robot.yml
```

---

## 📊 Relatórios

### Robot Framework (HTML)

Após executar os testes:
```bash
# Abrir relatório
open results/report.html  # Mac
start results/report.html # Windows
xdg-open results/report.html # Linux
```

### Allure Reports
```bash
# Gerar relatório Allure
allure generate results -o allure-report --clean

# Abrir relatório
allure open allure-report
```

---

## 🏷️ Tags

Os testes estão organizados por tags para execução seletiva:

| Tag | Descrição |
|-----|-----------|
| `smoke` | Testes críticos (execução rápida) |
| `regression` | Suite completa de regressão |
| `auth` | Testes de autenticação |
| `books` | Testes de gerenciamento de livros |
| `ui` | Testes de interface |
| `api` | Testes de API |
| `accessibility` | Testes de acessibilidade WCAG |
| `positive` | Casos de sucesso |
| `negative` | Casos de erro |

**Exemplos:**
```bash
# Apenas smoke tests
robot -d results -i smoke tests/

# Auth UI + API
robot -d results -i "auth AND (ui OR api)" tests/

# Tudo exceto accessibility
robot -d results -e accessibility tests/
```

---

## ♿ Testes de Acessibilidade

Validamos conformidade **WCAG 2.1 Level AA** usando:

- ✅ Navegação por teclado
- ✅ ARIA labels
- ✅ Contrast ratios
- ✅ Screen reader compatibility
- ✅ Form labels
- ✅ Focus indicators
```bash
# Executar apenas testes de acessibilidade
robot -d results tests/accessibility/
```

---

## 🔧 Configuração

### Variáveis de Ambiente

Edite `environment.resource`:
```robot
*** Variables ***
${BASE_URL}        http://localhost:5173    # Frontend URL
${API_URL}         http://localhost:3000    # Backend URL
${BROWSER}         chromium                 # chromium | firefox | webkit
${HEADLESS}        False                    # True | False
${USER_EMAIL}      test@email.com           # Usuário padrão
${USER_PASS}       123456                   # Senha padrão
${TIMEOUT}         10s                      # Timeout global
```

---

## 🐛 Troubleshooting

### Erro: "Browser not found"
```bash
# Reinstalar browsers do Playwright
rfbrowser init
```

### Erro: "Connection refused"
```bash
# Verificar se backend e frontend estão rodando
curl http://localhost:3000/health
curl http://localhost:5173
```

### Testes lentos
```bash
# Ativar modo headless
# Edite environment.resource: ${HEADLESS} = True

# Ou via linha de comando
robot -d results -v HEADLESS:True tests/
```

### Screenshots de falhas
```bash
# Screenshots são salvos automaticamente em results/
# Veja: results/browser/screenshot/*.png
```

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona nova feature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

### Padrões

- ✅ Use Page Object Model
- ✅ Adicione tags aos testes
- ✅ Escreva keywords descritivas
- ✅ Documente casos complexos
- ✅ Mantenha data-testid consistentes

---

## 📚 Recursos

- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [Browser Library Docs](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [RequestsLibrary Docs](https://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html)
- [Allure Documentation](https://docs.qameta.io/allure/)

---

## 📝 Licença

Este projeto está sob a licença MIT.

---

## 👨‍💻 Autor

**Thiago Rocha**

- GitHub: [@thiago8rocha](https://github.com/thiago8rocha)
- LinkedIn: [Seu LinkedIn](https://linkedin.com/in/seu-perfil)

---

<div align="center">
  <p>Feito com 🤖 e ☕ por <a href="https://github.com/thiago8rocha">Thiago Rocha</a></p>
  <p>⭐ Se este projeto te ajudou, considere dar uma estrela!</p>
</div>