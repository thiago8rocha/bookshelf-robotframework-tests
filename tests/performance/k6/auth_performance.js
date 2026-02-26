import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

// ============================================================
// LOAD TEST - Auth Endpoints (baseline)
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const loginDuration    = new Trend('login_duration',    true);
const registerDuration = new Trend('register_duration', true);

export const options = {
    stages: [
        { duration: '30s', target: 10 },
        { duration: '1m',  target: 10 },
        { duration: '30s', target: 0  },
    ],
    thresholds: {
        'login_duration':    ['p(95)<1500'],
        'register_duration': ['p(95)<2000'],
        'http_req_failed':   ['rate<0.05'],
        'http_req_duration': ['p(95)<2000'],
    },
};

export default function () {
    const timestamp = Date.now();
    const email     = `perf_${timestamp}_${Math.random().toString(36).slice(2, 7)}@test.com`;
    const password  = 'Test@123456';

    const registerStart = Date.now();
    const registerRes = http.post(
        `${API_URL}/auth/register`,
        JSON.stringify({ name: `Perf User`, email, password }),
        { headers: { 'Content-Type': 'application/json' } }
    );
    registerDuration.add(Date.now() - registerStart);

    check(registerRes, {
        'register status 201':    (r) => r.status === 201,
        'register retorna token': (r) => {
            try { return !!JSON.parse(r.body).token; } catch { return false; }
        },
    });

    const loginStart = Date.now();
    const loginRes = http.post(
        `${API_URL}/auth/login`,
        JSON.stringify({ email, password }),
        { headers: { 'Content-Type': 'application/json' } }
    );
    loginDuration.add(Date.now() - loginStart);

    check(loginRes, {
        'login status 200':    (r) => r.status === 200,
        'login retorna token': (r) => {
            try { return !!JSON.parse(r.body).token; } catch { return false; }
        },
    });

    sleep(1);
}
