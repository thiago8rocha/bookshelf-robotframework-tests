import http from 'k6/http';
import { check, sleep } from 'k6';
import { Trend } from 'k6/metrics';

// ============================================================
// LOAD TEST - Books Endpoints (baseline)
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const listDuration   = new Trend('list_books_duration',  true);
const createDuration = new Trend('create_book_duration', true);

export const options = {
    stages: [
        { duration: '30s', target: 10 },
        { duration: '1m',  target: 10 },
        { duration: '30s', target: 0  },
    ],
    thresholds: {
        'list_books_duration':  ['p(95)<1000'],
        'create_book_duration': ['p(95)<2000'],
        'http_req_failed':      ['rate<0.05'],
        'http_req_duration':    ['p(95)<2000'],
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
    return { token: JSON.parse(res.body).token };
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
