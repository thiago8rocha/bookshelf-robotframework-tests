---
name: debug-failing-test
description: Use when a Robot Framework test in this repo fails or is flaky, to tell an app bug from a test bug and fix the cause without Sleep or blind retries.
---

# Debug a failing or flaky test

1. Re-run just that test with more detail: `make test-file F=<file>` or, outside Docker,
   `python -m robot --loglevel DEBUG --variable HEADLESS:False -t "<test name>" -d results <file>`.
2. Read the evidence: `results/log.html` (keyword tree and the failing step) and `results/output.xml`.
   For the app side, `make logs` shows backend and frontend output.
3. Decide whose bug it is:
   - The API returned an unexpected status, or the UI shows a wrong result for a valid flow: app bug. Report it for
     `bookshelf-api` or `bookshelf-frontend`; do not loosen the assertion.
   - A `data-testid` is missing or renamed: fix the frontend, then the keyword.
   - Shared state: tests reusing `test@email.com`, a book title, or leftovers from a crashed run. Use a per-test user and clean up in teardown.
   - Timing: the step acts before the element is ready. Add `Wait For Elements State    <selector>    visible` (or `enabled`)
     before the action, or wait for the response. Never `Sleep` or raise global timeouts.
   - A URL match on the book list: the request has a query string.
4. Fix the cause, then prove it: `make test-file F=<file>` five times in a row, then the surrounding folder.
5. If only CI fails, compare the `robot-html-report` artifact with a local run. CI uses the compose network
   (`http://frontend:5173`, `http://backend:3000`) and the default branch of the app repos.
