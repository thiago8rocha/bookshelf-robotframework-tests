import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// ============================================================
// LOAD TEST - Auth Endpoints
// Objetivo: Validar comportamento sob carga normal esperada
// Padrão: ramp up → sustentado → ramp down
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const loginDuration    = new Trend('login_duration',    true);
const registerDuration = new Trend('register_duration', true);
const errorRate        = new Rate('error_rate');
const requestsTotal    = new Counter('requests_total');

export const options = {
    stages: [
        { duration: '30s', target: 10 },
        { duration: '1m',  target: 10 },
        { duration: '30s', target: 0  },
    ],
    thresholds: {
        'login_duration':    ['p(95)<3000'],
        'register_duration': ['p(95)<4000'],
        'error_rate':        ['rate<0.05'],
        'http_req_failed':   ['rate<0.05'],
        'http_req_duration': ['p(95)<4000'],
    },
};

export function setup() {
    return { timestamp: Date.now() };
}

export default function () {
    const timestamp = Date.now();
    const email     = `load_${timestamp}_${Math.random().toString(36).slice(2, 7)}@test.com`;
    const password  = 'Test@123456';

    const registerStart = Date.now();
    const registerRes = http.post(
        `${API_URL}/api/auth/register`,
        JSON.stringify({ name: `Load User ${timestamp}`, email, password }),
        { headers: { 'Content-Type': 'application/json' }, tags: { endpoint: 'register' } }
    );
    registerDuration.add(Date.now() - registerStart);
    requestsTotal.add(1);

    const registerOk = check(registerRes, {
        'register status 201':    (r) => r.status === 201,
        'register retorna token': (r) => {
            try { return !!JSON.parse(r.body).token; } catch { return false; }
        },
    });
    if (!registerOk) errorRate.add(true);

    const loginStart = Date.now();
    const loginRes = http.post(
        `${API_URL}/api/auth/login`,
        JSON.stringify({ email, password }),
        { headers: { 'Content-Type': 'application/json' }, tags: { endpoint: 'login' } }
    );
    loginDuration.add(Date.now() - loginStart);
    requestsTotal.add(1);

    const loginOk = check(loginRes, {
        'login status 200':    (r) => r.status === 200,
        'login retorna token': (r) => {
            try { return !!JSON.parse(r.body).token; } catch { return false; }
        },
    });
    if (!loginOk) errorRate.add(true);

    sleep(1);
}
