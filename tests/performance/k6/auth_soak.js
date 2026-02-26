import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// ============================================================
// SOAK TEST - Auth Endpoints
// Objetivo: Detectar memory leaks, degradação gradual de
// performance e problemas que só aparecem após uso prolongado
// Padrão: carga moderada sustentada por longo período
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const loginDuration    = new Trend('login_duration',    true);
const registerDuration = new Trend('register_duration', true);
const errorRate        = new Rate('error_rate');
const requestsTotal    = new Counter('requests_total');

export const options = {
    stages: [
        { duration: '1m',  target: 5  },  // ramp up gradual
        { duration: '10m', target: 5  },  // carga sustentada (ajuste para ambiente)
        { duration: '1m',  target: 0  },  // ramp down
    ],
    thresholds: {
        // Thresholds mais estritos — sistema não deve degradar com o tempo
        'login_duration':    ['p(95)<4000', 'p(99)<6000'],
        'register_duration': ['p(95)<5000', 'p(99)<8000'],
        'error_rate':        ['rate<0.02'],  // máximo 2% de erro em carga sustentada
        'http_req_failed':   ['rate<0.02'],
        'http_req_duration': ['p(95)<4000'],
    },
};

export function setup() {
    return { startTime: Date.now() };
}

export default function () {
    const timestamp = Date.now();
    const email     = `soak_${timestamp}_${Math.random().toString(36).slice(2, 7)}@test.com`;
    const password  = 'Test@123456';

    // Register
    const registerStart = Date.now();
    const registerRes = http.post(
        `${API_URL}/auth/register`,
        JSON.stringify({ name: `Soak User ${timestamp}`, email, password }),
        { headers: { 'Content-Type': 'application/json' }, tags: { endpoint: 'register' } }
    );
    registerDuration.add(Date.now() - registerStart);
    requestsTotal.add(1);

    const registerOk = check(registerRes, {
        'register status 201': (r) => r.status === 201,
        'register retorna token': (r) => {
            try { return !!JSON.parse(r.body).token; } catch { return false; }
        },
    });
    if (!registerOk) errorRate.add(true);

    if (!registerOk) { sleep(1); return; }

    // Login
    const loginStart = Date.now();
    const loginRes = http.post(
        `${API_URL}/auth/login`,
        JSON.stringify({ email, password }),
        { headers: { 'Content-Type': 'application/json' }, tags: { endpoint: 'login' } }
    );
    loginDuration.add(Date.now() - loginStart);
    requestsTotal.add(1);

    const loginOk = check(loginRes, {
        'login status 200': (r) => r.status === 200,
        'login retorna token': (r) => {
            try { return !!JSON.parse(r.body).token; } catch { return false; }
        },
    });
    if (!loginOk) errorRate.add(true);

    sleep(2);
}
