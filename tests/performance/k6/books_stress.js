import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Trend } from 'k6/metrics';

// ============================================================
// STRESS TEST - Books Endpoints
// Objetivo: Encontrar o ponto de ruptura em operações CRUD
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const listDuration   = new Trend('list_books_duration',   true);
const createDuration = new Trend('create_book_duration',  true);
const updateDuration = new Trend('update_book_duration',  true);
const deleteDuration = new Trend('delete_book_duration',  true);
const errorRate      = new Counter('error_rate');
const requestsTotal  = new Counter('requests_total');

export const options = {
    stages: [
        { duration: '30s', target: 10 },
        { duration: '30s', target: 20 },
        { duration: '30s', target: 40 },
        { duration: '30s', target: 60 },
        { duration: '30s', target: 80 },
        { duration: '30s', target: 0  },
    ],
    thresholds: {
        'list_books_duration':  ['p(95)<5000'],
        'create_book_duration': ['p(95)<8000'],
        'update_book_duration': ['p(95)<8000'],
        'delete_book_duration': ['p(95)<8000'],
        'error_rate':           ['rate<0.30'],
        'http_req_failed':      ['rate<0.30'],
    },
};

export function setup() {
    const res = http.post(
        `${API_URL}/auth/register`,
        JSON.stringify({
            name: 'Stress Books User',
            email: `stress_books_${Date.now()}@test.com`,
            password: 'Test@123456',
        }),
        { headers: { 'Content-Type': 'application/json' } }
    );
    const body = JSON.parse(res.body);
    return { token: body.token };
}

export default function (data) {
    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${data.token}`,
    };

    const listStart = Date.now();
    const listRes = http.get(`${API_URL}/books`, { headers, tags: { endpoint: 'list' } });
    listDuration.add(Date.now() - listStart);
    requestsTotal.add(1);
    if (!check(listRes, { 'list status 200': (r) => r.status === 200 })) errorRate.add(1);

    const createStart = Date.now();
    const createRes = http.post(
        `${API_URL}/books`,
        JSON.stringify({ title: `Stress Book ${Date.now()}`, author: 'Stress Author', year: 2024 }),
        { headers, tags: { endpoint: 'create' } }
    );
    createDuration.add(Date.now() - createStart);
    requestsTotal.add(1);
    if (!check(createRes, { 'create status 201': (r) => r.status === 201 })) {
        errorRate.add(1);
        sleep(0.3);
        return;
    }

    const bookId = JSON.parse(createRes.body).id;

    const updateStart = Date.now();
    const updateRes = http.put(
        `${API_URL}/books/${bookId}`,
        JSON.stringify({ title: `Stress Book Updated`, author: 'Stress Author', year: 2025 }),
        { headers, tags: { endpoint: 'update' } }
    );
    updateDuration.add(Date.now() - updateStart);
    requestsTotal.add(1);
    if (!check(updateRes, { 'update status 200': (r) => r.status === 200 })) errorRate.add(1);

    const deleteStart = Date.now();
    const deleteRes = http.del(`${API_URL}/books/${bookId}`, null, { headers, tags: { endpoint: 'delete' } });
    deleteDuration.add(Date.now() - deleteStart);
    requestsTotal.add(1);
    if (!check(deleteRes, { 'delete status 200': (r) => r.status === 200 })) errorRate.add(1);

    sleep(0.3);
}
