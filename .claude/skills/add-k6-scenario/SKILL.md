---
name: add-k6-scenario
description: Use when adding or wiring a K6 performance script (load, spike, soak, stress) in this repo so it runs through Robot and shows up in Allure.
---

# Add a K6 scenario

How it works today: `tests/performance/performance.robot` calls `Run K6 Test` (`resources/helpers/performance/k6.resource`)
for a script in `tests/performance/k6/`, asserts with `K6 Should Pass` (the K6 exit code, so thresholds decide) and attaches the
summary with `Attach Performance Results To Allure` (`AllurePerformance.py`). Only `auth_performance.js` and `books_performance.js`
are wired; the `*_load`, `*_spike`, `*_soak` and `*_stress` scripts exist but no test runs them yet.

1. Script: copy the closest file in `tests/performance/k6/`. `API_URL` comes from `__ENV.API_URL` (default `http://localhost:3000`).
   Define `options.stages` and `options.thresholds`, and avoid registering a new user on every iteration (bcrypt becomes the bottleneck).
2. Test case in `performance.robot`, following the two existing ones:

   ```
   Books Spike Should Meet Thresholds
       [Documentation]    ...
       [Tags]    performance    spike    books
       ${result}=    Run K6 Test    script=${SCRIPTS_DIR}/books_spike.js    output=books_spike    test_type=spike
       K6 Should Pass    ${result}
       Attach Performance Results To Allure    ${result}    Books - Spike Test
   ```

3. Tags decide where it runs: add `slow` for long runs (soak, about 12 minutes) and `stress` for stress profiles. The default
   `make test` and the CI `all` suite exclude both; they run with `all-full`, `performance-full` or `make test-tag T=slow`.
4. Run: `make test-file F=tests/performance/performance.robot`. K6 is installed in the Docker image; outside Docker pass
   `--variable K6_BINARY:k6`. Summaries go to `results/performance/<output>_summary.json`.
5. Keep thresholds tolerant enough for the shared CI runner but tight enough to catch regressions; do not raise them just to make a run pass.
