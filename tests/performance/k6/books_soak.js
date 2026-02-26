import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// ============================================================
// SOAK TEST - Books Endpoints
// Objetivo: Detectar vazamentos de memória e degradação
// em operações CRUD sustentadas por longo período
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
        { duration: '1m',  target: 5 },
        { duration: '10m', target: 5 },
        { duration: '1m',  target: 0 },
    ],
    thresholds: {
        'list_books_duration':  ['p(95)<1000', 'p(99)<2000'],
        'create_book_duration': ['p(95)<2000', 'p(99)<3000'],
        'update_book_duration': ['p(95)<2000', 'p(99)<3000'],
        'delete_book_duration': ['p(95)<2000', 'p(99)<3000'],
        'error_rate':           ['rate<0.02'],
        'http_req_failed':      ['rate<0.02'],
        'http_req_duration':    ['p(95)<2000'],
    },
};

export function setup() {
    const res = http.post(
        `${API_URL}/auth/register`,
        JSON.stringify({
            name: 'Soak Books User',
            email: `soak_books_${Date.now()}@test.com`,
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
    if (!check(listRes, { 'list status 200': (r) => r.status === 200 })) errorRate.add(true);

    const createStart = Date.now();
    const createRes = http.post(
        `${API_URL}/books`,
        JSON.stringify({ title: `Soak Book ${Date.now()}`, author: 'Soak Author', year: 2024 }),
        { headers, tags: { endpoint: 'create' } }
    );
    createDuration.add(Date.now() - createStart);
    requestsTotal.add(1);
    if (!check(createRes, { 'create status 201': (r) => r.status === 201 })) {
        errorRate.add(true);
        sleep(2);
        return;
    }

    const bookId = JSON.parse(createRes.body).id;

    const updateStart = Date.now();
    const updateRes = http.put(
        `${API_URL}/books/${bookId}`,
        JSON.stringify({ title: `Soak Book Updated ${Date.now()}`, author: 'Soak Author', year: 2025 }),
        { headers, tags: { endpoint: 'update' } }
    );
    updateDuration.add(Date.now() - updateStart);
    requestsTotal.add(1);
    if (!check(updateRes, { 'update status 200': (r) => r.status === 200 })) errorRate.add(true);

    const deleteStart = Date.now();
    const deleteRes = http.del(`${API_URL}/books/${bookId}`, null, { headers, tags: { endpoint: 'delete' } });
    deleteDuration.add(Date.now() - deleteStart);
    requestsTotal.add(1);
    if (!check(deleteRes, { 'delete status 200': (r) => r.status === 200 })) errorRate.add(true);

    sleep(2);
}
