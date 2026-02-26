import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

// ============================================================
// LOAD TEST - Books Endpoints
// Thresholds calibrados para ambiente CI (Docker, recursos limitados)
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const listDuration   = new Trend('list_books_duration',  true);
const createDuration = new Trend('create_book_duration', true);

export const options = {
    stages: [
        { duration: '20s', target: 5 },
        { duration: '40s', target: 5 },
        { duration: '20s', target: 0 },
    ],
    thresholds: {
        'list_books_duration':  ['p(95)<3000'],
        'create_book_duration': ['p(95)<5000'],
        'http_req_failed':      ['rate<0.10'],
        'http_req_duration':    ['p(95)<5000'],
    },
};

export function setup() {
    const res = http.post(
        `${API_URL}/auth/register`,
        JSON.stringify({
            name: 'Perf Books User',
            email: `perf_books_${Date.now()}@test.com`,
            password: 'Test@123456',
        }),
        { headers: { 'Content-Type': 'application/json' } }
    );
    const body = JSON.parse(res.body);
    if (!body.token) {
        throw new Error(`Setup falhou — register retornou: ${res.body}`);
    }
    return { token: body.token };
}

export default function (data) {
    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${data.token}`,
    };

    const listStart = Date.now();
    const listRes = http.get(`${API_URL}/books`, { headers });
    listDuration.add(Date.now() - listStart);
    check(listRes, { 'list status 200': (r) => r.status === 200 });

    const createStart = Date.now();
    const createRes = http.post(
        `${API_URL}/books`,
        JSON.stringify({ title: `Perf Book ${Date.now()}`, author: 'Author', year: 2024 }),
        { headers }
    );
    createDuration.add(Date.now() - createStart);
    const ok = check(createRes, { 'create status 201': (r) => r.status === 201 });

    if (ok) {
        const bookId = JSON.parse(createRes.body).id;
        http.del(`${API_URL}/books/${bookId}`, null, { headers });
    }

    sleep(1);
}
