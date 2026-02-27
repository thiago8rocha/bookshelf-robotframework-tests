import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// ============================================================
// STRESS TEST - Auth Endpoints
// Objetivo: Encontrar o ponto de ruptura do sistema,
// aumentando progressivamente a carga até falhas aparecerem
// Padrão: escalonamento contínuo até colapso/limite
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3001';

const loginDuration    = new Trend('login_duration',    true);
const registerDuration = new Trend('register_duration', true);
const errorRate        = new Rate('error_rate');
const requestsTotal    = new Counter('requests_total');

export const options = {
    stages: [
        { duration: '30s', target: 10  },  // aquecimento
        { duration: '30s', target: 20  },  // carga normal
        { duration: '30s', target: 40  },  // carga elevada
        { duration: '30s', target: 60  },  // stress
        { duration: '30s', target: 80  },  // stress alto
        { duration: '30s', target: 0   },  // ramp down — observar recuperação
    ],
    thresholds: {
        // No stress test os thresholds documentam o limite, não bloqueiam o teste
        // O objetivo é ver ATÉ ONDE o sistema aguenta antes de degradar
        'login_duration':    ['p(95)<8000'],
        'register_duration': ['p(95)<10000'],
        'error_rate':        ['rate<0.30'],  // até 30% — documenta degradação
        'http_req_failed':   ['rate<0.30'],
    },
};

export function setup() {
    return { startTime: Date.now() };
}

export default function () {
    const timestamp = Date.now();
    const email     = `stress_${timestamp}_${Math.random().toString(36).slice(2, 7)}@test.com`;
    const password  = 'Test@123456';

    // Register
    const registerStart = Date.now();
    const registerRes = http.post(
        `${API_URL}/api/auth/register`,
        JSON.stringify({ name: `Stress User ${timestamp}`, email, password }),
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
    if (!registerOk) { errorRate.add(true); sleep(0.5); return; }

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

    sleep(0.5);
}
