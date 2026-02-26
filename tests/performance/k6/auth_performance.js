import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

// ============================================================
// LOAD TEST - Auth Endpoints
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const loginDuration = new Trend('login_duration', true);

export const options = {
    stages: [
        { duration: '20s', target: 5 },
        { duration: '40s', target: 5 },
        { duration: '20s', target: 0 },
    ],
    thresholds: {
        'login_duration':  ['p(95)<5000'],
        'http_req_failed': ['rate<0.10'],
        'http_req_duration': ['p(95)<5000'],
    },
};

export function setup() {
    const email    = `perf_auth_${Date.now()}@test.com`;
    const password = 'Test@123456';

    const res = http.post(
        `${API_URL}/api/auth/register`,
        JSON.stringify({ name: 'Perf Auth User', email, password }),
        { headers: { 'Content-Type': 'application/json' } }
    );

    if (res.status !== 201) {
        throw new Error(`Setup register falhou: status=${res.status} body=${res.body}`);
    }

    return { email, password };
}

export default function (data) {
    const start = Date.now();
    const res = http.post(
        `${API_URL}/api/auth/login`,
        JSON.stringify({ email: data.email, password: data.password }),
        { headers: { 'Content-Type': 'application/json' } }
    );
    loginDuration.add(Date.now() - start);

    check(res, {
        'login status 200':    (r) => r.status === 200,
        'login retorna token': (r) => {
            try { return !!JSON.parse(r.body).token; } catch { return false; }
        },
    });

    sleep(1);
}
