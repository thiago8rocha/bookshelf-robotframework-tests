import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// ============================================================
// SPIKE TEST - Auth Endpoints
// Objetivo: Simular um pico repentino de usuários e verificar
// se o sistema se recupera após o pico
// Padrão: baixo → pico súbito → baixo novamente
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const loginDuration   = new Trend('login_duration',    true);
const registerDuration = new Trend('register_duration', true);
const errorRate       = new Rate('error_rate');
const requestsTotal   = new Counter('requests_total');

export const options = {
    stages: [
        { duration: '10s', target: 2  },  // baseline baixo
        { duration: '10s', target: 50 },  // pico súbito
        { duration: '30s', target: 50 },  // sustenta o pico
        { duration: '10s', target: 2  },  // queda súbita
        { duration: '30s', target: 2  },  // verifica recuperação
    ],
    thresholds: {
        // Durante o pico, p95 pode ser maior — threshold mais tolerante
        'login_duration':    ['p(95)<5000'],
        'register_duration': ['p(95)<6000'],
        'error_rate':        ['rate<0.15'],  // até 15% de erro aceitável no pico
        'http_req_failed':   ['rate<0.15'],
    },
};

export function setup() {
    return { timestamp: Date.now() };
}

export default function () {
    const timestamp = Date.now();
    const email     = `spike_${timestamp}_${Math.random().toString(36).slice(2, 7)}@test.com`;
    const password  = 'Test@123456';

    // Register
    const registerStart = Date.now();
    const registerRes = http.post(
        `${API_URL}/api/auth/register`,
        JSON.stringify({ name: `Spike User ${timestamp}`, email, password }),
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

    // Login
    const loginStart = Date.now();
    const loginRes = http.post(
        `${API_URL}/api/auth/login`,
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

    sleep(1);
}
