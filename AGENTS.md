# AGENTS.md

## What this is

Robot Framework 7.0 suite for BookShelf (React/Vite frontend + Express/PostgreSQL API): UI and E2E tests with the Browser
library (Playwright underneath), API tests with RequestsLibrary, accessibility (WCAG) checks and K6 performance tests, all
reported with Allure. It is a public portfolio project. The sister suite in Playwright lives in `bookshelf-playwright-tests`.

## Layout

- `base/ui.resource`, `base/api.resource`: library imports and suite/test setup and teardown.
- `resources/actions/`: user-level keywords (`login`, `register`, `books`).
- `resources/helpers/`: technical keywords: `api/` (auth, HTTP), `ui/browser.resource`, `common/data.resource`
  (data generation and API setup), `performance/k6.resource` and `AllurePerformance.py`.
- `environment.resource`: URLs, browser options and default test data.
- `tests/api`, `tests/ui/{login,books,dashboard,accessibility,store}`, `tests/e2e`, `tests/performance` (with `k6/*.js`).
- `Makefile`, `docker-compose.yml`, `Dockerfile`: the supported way to run everything.

## Commands

- Whole suite (without `stress` and `slow`): `make test`. By kind: `make test-api`, `make test-ui`, `make test-e2e`,
  `make test-performance`, `make test-smoke`.
- One file: `make test-file F=tests/ui/login/login.robot`. One tag: `make test-tag T=logout`.
- Stack: `make up`, `make down`, `make logs`, `make build`, `make rebuild`, `make clean`.
- Report: `make report` opens `results/log.html`.
- Without Docker: `pip install -r requirements.txt allure-robotframework`, `rfbrowser init`, then for example
  `python -m robot --listener allure_robotframework -d results tests/ui/login/login.robot`. Performance tests also need K6.
- There is no linter configured.

## How to run against the app

`make up` builds `database`, `backend` and `frontend` from `../bookshelf-api` and `../bookshelf-frontend`
(override with `BOOKSHELF_API_PATH` and `BOOKSHELF_FRONTEND_PATH`). Host ports: frontend 5174, backend 3001, Postgres 5433.
Inside the compose network the `robot` container uses `BASE_URL=http://frontend:5173` and `API_URL=http://backend:3000`.

Outside Docker, `environment.resource` defaults to `http://localhost:5173` and `http://localhost:3000`; `BASE_URL`, `API_URL`
and `BROWSER` are read from the environment, and `HEADLESS` is a Robot variable (`--variable HEADLESS:False`).

## Conventions

- Selectors: `data-testid=<id>` (Browser library). `data-testid` values are kebab-case and a public contract of the frontend;
  list items use `name-${id}`. A missing id is fixed in `bookshelf-frontend`, not with a fragile selector.
- Keep selectors and waits inside keywords of `resources/actions` (high level) or `resources/helpers` (technical); test files
  read as user steps.
- Waits: `Wait For Elements State` and `Wait For Load State`. Do not add `Sleep`; the ones in `login.robot`, `wcag.robot`,
  `books.resource` and `login.resource` are legacy.
- Test names are Title Case sentences (`Old User Can Create Book With All Fields`). Every test has `[Documentation]` and `[Tags]`:
  area (`books`, `auth`...), kind (`positive`, `negative`), layer (`ui`, `api`), selection (`smoke`, `regression`) and a unique
  `ID=<PREFIX><NNN>`. Prefixes in use: ACCESS, API, AUTH, BOOKS, BSTAT, DASH, E2E, LOGIN, LOGOUT, MKT, REGISTER, RESP, SESSION, STORE.
  Existing documentation strings are in Portuguese; write new ones in English.
- Data: each test creates its own user through the API (`Create User With Books`, `Create Fresh User And Login`,
  `Generate New Book`, `Login Via API`) and removes its books in teardown (`Delete All User Books Via API`).
  FakerLibrary runs with `pt_BR`.

## CI

`.github/workflows/robot.yml` runs on push and pull request to `master` or `main`, and on manual dispatch with `test_suite`
(`all`, `all-full`, `api`, `ui`, `e2e`, `performance`, `performance-full`, `smoke`, `regression`, `fresh-user`, `negative`)
and `extra_args`. It checks out `bookshelf-web/bookshelf-api` and `bookshelf-web/bookshelf-frontend`, runs the compose stack,
publishes Allure to GitHub Pages and opens an issue when tests fail on `master`/`main`.

Artifacts: `allure-results`, `allure-report`, `robot-html-report`. The "Run E2E Tests" workflow in the API and frontend repos
can dispatch it (secret `E2E_DISPATCH_TOKEN`).

## Git

History is mixed: older commits use `feat:` and `fix:`, recent ones are plain imperative sentences. Prefer `type: summary` in
lowercase imperative. Do not commit or push unless asked. Do not add AI-attribution trailers to commits or pull requests.

## Gotchas

- The book list request has a query string (`page`, `limit`, `sortBy`...); match it by pattern, never by an exact `/api/books` URL.
- Google Books is called directly by the browser and must never be hit for real. No test here uses it today; if one needs it,
  mock it the way the Playwright suite does.
- The service worker is not registered under automation (`navigator.webdriver`). The frontend is served at `/` in dev and E2E.
- Payments are simulated and the Pix code is not payable.
- `K6_BINARY` defaults to `/usr/bin/k6` (the Docker image). Outside Docker pass `--variable K6_BINARY:k6`.
- Only `*_performance.js` scripts are wired into `tests/performance/performance.robot`; the load, spike, soak and stress scripts
  are not run by any test yet.
- `requirements.txt` pins the Robot libraries but not `allure-robotframework`, and the Dockerfile installs unpinned versions.
  Docker is the reference environment.
- `.gitignore` ignores `package-lock.json`, `.env.*`, `results/` and Allure output.

## Definition of done

- The changed suite passes with `make test-file F=<file>` five times in a row, and `make test` still passes.
- No `Sleep` and no real third-party call was added.
- Every new test has documentation, tags and a unique `ID=`.
