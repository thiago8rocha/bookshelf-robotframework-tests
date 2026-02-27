import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// ============================================================
// SPIKE TEST - Books Endpoints
// Objetivo: Simular pico súbito de usuários em operações CRUD
// ============================================================

const API_URL = __ENV.API_URL || 'http://localhost:3000';

const listDuration   = new Trend('list_books_duration',   true);
const createDuration = new Trend('create_book_duration',  true);
const updateDuration = new Trend('update_book_duration',  true);
const deleteDuration = new Trend('delete_book_duration',  true);
const errorRate      = new Rate('error_rate');
const requestsTotal  = new Counter('requests_total');

export const options = {
    stages: [
        { duration: '10s', target: 2  },
        { duration: '10s', target: 50 },
        { duration: '30s', target: 50 },
        { duration: '10s', target: 2  },
        { duration: '30s', target: 2  },
    ],
    thresholds: {
        'list_books_duration':  ['p(95)<3000'],
        'create_book_duration': ['p(95)<5000'],
        'update_book_duration': ['p(95)<5000'],
        'delete_book_duration': ['p(95)<5000'],
        'error_rate':           ['rate<0.15'],
        'http_req_failed':      ['rate<0.15'],
    },
};

export function setup() {
    const res = http.post(
        `${API_URL}/api/auth/register`,
        JSON.stringify({
            name: 'Spike Books User',
            email: `spike_books_${Date.now()}@test.com`,
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

    // List
    const listStart = Date.now();
    const listRes = http.get(`${API_URL}/api/books`, { headers, tags: { endpoint: 'list' } });
    listDuration.add(Date.now() - listStart);
    requestsTotal.add(1);
    const listOk = check(listRes, { 'list status 200': (r) => r.status === 200 });
    if (!listOk) errorRate.add(true);

    // Create
    const createStart = Date.now();
    const createRes = http.post(
        `${API_URL}/api/books`,
        JSON.stringify({ title: `Spike Book ${Date.now()}`, author: 'Spike Author', year: 2024 }),
        { headers, tags: { endpoint: 'create' } }
    );
    createDuration.add(Date.now() - createStart);
    requestsTotal.add(1);
    const createOk = check(createRes, { 'create status 201': (r) => r.status === 201 });
    if (!createOk) { errorRate.add(true); sleep(0.5); return; }

    const bookId = JSON.parse(createRes.body).book.id;

    // Update
    const updateStart = Date.now();
    const updateRes = http.put(
        `${API_URL}/api/books/${bookId}`,
        JSON.stringify({ title: `Spike Book Updated ${Date.now()}`, author: 'Spike Author', year: 2025 }),
        { headers, tags: { endpoint: 'update' } }
    );
    updateDuration.add(Date.now() - updateStart);
    requestsTotal.add(1);
    const updateOk = check(updateRes, { 'update status 200': (r) => r.status === 200 });
    if (!updateOk) errorRate.add(true);

    // Delete
    const deleteStart = Date.now();
    const deleteRes = http.del(`${API_URL}/api/books/${bookId}`, null, { headers, tags: { endpoint: 'delete' } });
    deleteDuration.add(Date.now() - deleteStart);
    requestsTotal.add(1);
    const deleteOk = check(deleteRes, { 'delete status 200': (r) => r.status === 200 });
    if (!deleteOk) errorRate.add(true);

    sleep(0.5);
}
