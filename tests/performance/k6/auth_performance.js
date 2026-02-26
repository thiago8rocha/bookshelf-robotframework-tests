import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

// ============================================================
// LOAD TEST - Auth Endpoints
// Thresholds calibrados para ambiente CI (Docker, recursos limitados)
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const loginDuration    = new Trend('login_duration',    true);
const registerDuration = new Trend('register_duration', true);

export const options = {
    stages: [
        { duration: '20s', target: 5 },
        { duration: '40s', target: 5 },
        { duration: '20s', target: 0 },
    ],
    thresholds: {
        'login_duration':    ['p(95)<5000'],
        'register_duration': ['p(95)<5000'],
        'http_req_failed':   ['rate<0.10'],
        'http_req_duration': ['p(95)<5000'],
    },
};

export default function () {
    const timestamp = Date.now();
    const uid   = Math.random().toString(36).slice(2, 9);
    const email    = `perf_${timestamp}_${uid}@test.com`;
    const password = 'Test@123456';

    const registerStart = Date.now();
    const registerRes = http.post(
        `${API_URL}/auth/register`,
        JSON.stringify({ name: 'Perf User', email, password }),
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
