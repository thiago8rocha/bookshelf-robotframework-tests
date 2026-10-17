---
name: run-tests
description: Use when running this Robot Framework suite or part of it, locally with Docker or without it, through GitHub Actions, and when opening the results.
---

# Run tests

## Local with Docker (reference)

1. `make up` builds and starts `database`, `backend` and `frontend` from `../bookshelf-api` and `../bookshelf-frontend`
   (override with `BOOKSHELF_API_PATH`, `BOOKSHELF_FRONTEND_PATH`). The frontend is on host port 5174, the backend on 3001.
2. Run:
   - everything except `stress` and `slow`: `make test`
   - `make test-api`, `make test-ui`, `make test-e2e`, `make test-performance`, `make test-smoke`
   - one file: `make test-file F=tests/ui/login/login.robot`
   - one tag: `make test-tag T=logout`
3. `make logs` follows the app containers; `make down` stops them and removes volumes; `make rebuild` after Dockerfile changes.
4. Results are in `results/` (`log.html`, `report.html`, `output.xml`); `make report` opens `results/log.html`.

## Local without Docker

Needs the app on `http://localhost:5173` (frontend) and `http://localhost:3000` (API), Python 3.11 and Node 20.
`pip install -r requirements.txt allure-robotframework`, `rfbrowser init`, then:
`python -m robot --listener allure_robotframework -d results tests/ui/login/login.robot`.

Useful options: `--include smoke`, `--exclude slow`, `--variable HEADLESS:False` to watch the browser,
`--variable BASE_URL:http://localhost:5174`. Performance tests also need K6: add `--variable K6_BINARY:k6`.

## CI

Workflow "Robot Framework Tests" (`.github/workflows/robot.yml`) runs on push and pull request to `master` or `main`.
Manual run: Actions, Robot Framework Tests, Run workflow, choose `test_suite`
(`all`, `all-full`, `api`, `ui`, `e2e`, `performance`, `performance-full`, `smoke`, `regression`, `fresh-user`, `negative`)
and optional `extra_args` such as `--include login`. The API and frontend repos can dispatch it from their "Run E2E Tests" workflow.

Results: Allure on GitHub Pages and the `allure-results`, `allure-report` and `robot-html-report` artifacts.
A failure on `master` or `main` opens an issue.
