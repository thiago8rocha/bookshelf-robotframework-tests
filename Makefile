## ─────────────────────────────────────────────────────────────────────────────
##  Bookshelf Tests — Makefile
##  Roda a suíte de testes via Docker sem precisar instalar nada localmente.
##
##  Uso rápido:
##    make test              → suíte completa
##    make test-api          → só testes de API
##    make test-ui           → só testes de UI
##    make test-e2e          → só testes E2E
##    make test-file F=tests/ui/login/login.robot
##    make up / make down    → subir/derrubar apenas a aplicação
##    make logs              → ver logs dos containers
##    make report            → abrir resultado no browser
## ─────────────────────────────────────────────────────────────────────────────

COMPOSE        := docker compose -f docker-compose.local.yml
ROBOT_CMD      := python -m robot --listener allure_robotframework -d results
APP_SERVICES   := database backend frontend

# Arquivo ou tag passados via linha de comando
F ?=
T ?=

.PHONY: help up down logs build test test-api test-ui test-e2e test-performance test-smoke test-tag test-file report clean rebuild

help:
	@echo ""
	@echo "  Bookshelf Tests — comandos disponíveis"
	@echo ""
	@echo "  Infraestrutura:"
	@echo "    make up              Sobe database, backend e frontend em background"
	@echo "    make down            Derruba todos os containers"
	@echo "    make logs            Mostra logs dos containers da aplicação"
	@echo "    make build           Reconstrói a imagem do robot (após mudanças no Dockerfile)"
	@echo "    make rebuild         Reconstrói TUDO do zero (--no-cache)"
	@echo "    make clean           Remove containers, volumes e imagens locais"
	@echo ""
	@echo "  Testes:"
	@echo "    make test            Roda a suíte completa"
	@echo "    make test-api        Roda apenas testes de API"
	@echo "    make test-ui         Roda apenas testes de UI"
	@echo "    make test-e2e        Roda apenas testes E2E (jornadas completas)"
	@echo "    make test-performance Roda apenas testes de performance (K6)"
	@echo "    make test-smoke      Roda apenas testes marcados com 'smoke'"
	@echo "    make test-tag T=logout    Roda testes com uma tag específica"
	@echo "    make test-file F=tests/ui/login/login.robot"
	@echo ""
	@echo "  Resultados:"
	@echo "    make report          Abre o relatório HTML no browser (results/log.html)"
	@echo ""
	@echo "    make test-status     Roda apenas testes de status de livros"
	
## ─────────────────────────────────────────────────────────────────────────────
##  INFRAESTRUTURA
## ─────────────────────────────────────────────────────────────────────────────

up:
	@echo "▶  Subindo aplicação..."
	$(COMPOSE) up -d --build $(APP_SERVICES)
	@echo "⏳ Aguardando healthchecks..."
	@for i in $$(seq 1 30); do \
		HEALTHY=$$($(COMPOSE) ps | grep -c "healthy" || true); \
		echo "   Serviços saudáveis: $$HEALTHY ($${i}/30)"; \
		if [ "$$HEALTHY" -ge 3 ]; then \
			echo "✅ Aplicação pronta em http://localhost:5174"; \
			break; \
		fi; \
		sleep 5; \
	done

down:
	@echo "⏹  Derrubando containers..."
	$(COMPOSE) down -v
	@echo "✅ Tudo parado."

logs:
	$(COMPOSE) logs -f $(APP_SERVICES)

build:
	$(COMPOSE) build robot

rebuild:
	$(COMPOSE) build --no-cache

clean:
	$(COMPOSE) down -v --rmi local
	@echo "✅ Containers, volumes e imagens locais removidos."

## ─────────────────────────────────────────────────────────────────────────────
##  TESTES
## ─────────────────────────────────────────────────────────────────────────────

# Helper interno: sobe a aplicação se não estiver rodando, executa os testes,
# não derruba (permite rodar make test várias vezes sem rebuild)
_run:
	@$(COMPOSE) ps | grep -q "healthy" || $(MAKE) up
	$(COMPOSE) run --rm robot $(ROBOT_CMD) $(ROBOT_ARGS)

test:
	$(MAKE) _run ROBOT_ARGS="--exclude stress --exclude slow tests"

test-api:
	$(MAKE) _run ROBOT_ARGS="tests/api"

test-ui:
	$(MAKE) _run ROBOT_ARGS="tests/ui"

test-e2e:
	$(MAKE) _run ROBOT_ARGS="tests/e2e"

test-status:
	$(MAKE) _run ROBOT_ARGS="tests/ui/books/books_status.robot"

test-performance:
	$(MAKE) _run ROBOT_ARGS="tests/performance"

test-smoke:
	$(MAKE) _run ROBOT_ARGS="--include smoke tests"

## make test-tag T=logout
test-tag:
	@test -n "$(T)" || (echo "❌ Informe a tag: make test-tag T=logout" && exit 1)
	$(MAKE) _run ROBOT_ARGS="--include $(T) tests"

## make test-file F=tests/ui/login/login.robot
test-file:
	@test -n "$(F)" || (echo "❌ Informe o arquivo: make test-file F=tests/ui/login/login.robot" && exit 1)
	$(MAKE) _run ROBOT_ARGS="$(F)"

## ─────────────────────────────────────────────────────────────────────────────
##  RESULTADOS
## ─────────────────────────────────────────────────────────────────────────────

report:
	@if [ -f results/log.html ]; then \
		echo "🌐 Abrindo results/log.html..."; \
		open results/log.html 2>/dev/null || xdg-open results/log.html 2>/dev/null || \
		echo "   Abra manualmente: results/log.html"; \
	else \
		echo "❌ Nenhum resultado encontrado. Rode make test primeiro."; \
	fi
