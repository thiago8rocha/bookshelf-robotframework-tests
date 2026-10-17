---
name: write-test
description: Use when adding a new Robot Framework test, keyword or scenario to this repo, so it follows the base/actions/helpers layering, tags, IDs and data-testid selectors.
---

# Write a test

1. Choose the location: `tests/api/`, `tests/ui/<login|books|dashboard|accessibility|store>/`, `tests/e2e/`. Add to the
   `.robot` file whose topic matches; create a new file only for a new topic. Open a neighbour first and mirror its
   `*** Settings ***` (Resource imports use relative paths such as `../../../base/ui.resource`).
2. Layering:
   - `base/ui.resource` / `base/api.resource`: setup and teardown (`Setup UI Test`, `Teardown UI Test`, `Create API Session`).
   - `resources/actions/*.resource`: what a user does (`User Creates Book`, `Login With Credentials`). New UI steps go here.
   - `resources/helpers/**`: technical keywords and data (`Login Via API`, `Create Book Via API`, `Generate New Book`,
     `Create User With Books`, `Delete All User Books Via API`).
   The `.robot` file should read as user steps; reusable selectors and waits live in keywords.
3. Selectors: `data-testid=<id>` only (for example `Click    data-testid=add-book-button`). If the frontend lacks the id,
   add it in `bookshelf-frontend` (kebab-case, list items `name-${id}`) and say so in the summary.
4. Data: create a user per test through the API (`Create User With Books`, `Create Fresh User And Login`) and delete the
   books in `Test Teardown`. Faker runs with `pt_BR`. Do not reuse `test@email.com` unless the test is about the default user
   (`Ensure Default User Exists`).
5. Waits: `Wait For Elements State    <selector>    visible    timeout=10s` or `Wait For Load State`. No `Sleep`.
6. Metadata on every test: `[Documentation]` (English) and `[Tags]` with area, kind (`positive`/`negative`), layer (`ui`/`api`),
   optionally `smoke`/`regression`, and a unique `ID=<PREFIX><NNN>`. Find the next free number with
   `grep -rhoE "ID=BOOKS[0-9]+" tests | sort | tail -1`, using the prefix of the area (ACCESS, API, AUTH, BOOKS, BSTAT, DASH,
   E2E, LOGIN, LOGOUT, MKT, REGISTER, RESP, SESSION, STORE).
7. Google Books is never hit for real, the book list URL has a query string, payments are simulated: see the gotchas in AGENTS.md.
8. Validate: `make test-file F=<file>` five times in a row, then the surrounding folder (`make test-ui` or `make test-api`).
   `python -m robot --dryrun <file>` catches syntax and missing-keyword errors quickly.
