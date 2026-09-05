const request = require('supertest');
const app = require('../server');
const { initDB, getDB } = require('../database');

const API_KEY = 'medicate-security-key-2026'; // matches .env or default

beforeAll(async () => {
  // Use in-memory DB for tests
  process.env.NODE_ENV = 'test';
  await initDB();
});

afterAll((done) => {
  const db = getDB();
  db.close(() => done());
});

describe('Security Monitoring API', () => {
  
  it('should reject requests without a valid token', async () => {
    const res = await request(app).get('/api/security/events');
    expect(res.statusCode).toBe(401);
  });

  it('should reject requests with invalid token', async () => {
    const res = await request(app)
      .get('/api/security/events')
      .set('Authorization', 'Bearer invalid-token');
    expect(res.statusCode).toBe(403);
  });

  it('should allow valid token and return empty events array initially', async () => {
    const res = await request(app)
      .get('/api/security/events')
      .set('Authorization', `Bearer ${API_KEY}`);
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual([]);
  });

  it('should log a new security event', async () => {
    const res = await request(app)
      .post('/api/security/events')
      .set('Authorization', `Bearer ${API_KEY}`)
      .send({
        type: 'SUCCESSFUL_LOGIN',
        userId: 'admin123',
        status: 'SUCCESS',
        description: 'User logged in successfully'
      });
    
    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.type).toBe('SUCCESSFUL_LOGIN');
  });

  it('should reject malformed events (missing type)', async () => {
    const res = await request(app)
      .post('/api/security/events')
      .set('Authorization', `Bearer ${API_KEY}`)
      .send({
        userId: 'admin123'
      });
    expect(res.statusCode).toBe(400);
    expect(res.body).toHaveProperty('errors');
  });

  it('should retrieve recent events', async () => {
    const res = await request(app)
      .get('/api/security/events/recent')
      .set('Authorization', `Bearer ${API_KEY}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
  });

  it('should fetch statistics', async () => {
    const res = await request(app)
      .get('/api/security/stats')
      .set('Authorization', `Bearer ${API_KEY}`);
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('totalEvents');
    expect(res.body.totalEvents).toBeGreaterThan(0);
  });

  it('should generate an alert on 5 failed logins', async () => {
    for (let i = 0; i < 5; i++) {
      await request(app)
        .post('/api/security/events')
        .set('Authorization', `Bearer ${API_KEY}`)
        .send({ type: 'FAILED_LOGIN' });
    }
    
    // Wait a brief moment for async db write in processAlertRules
    await new Promise(resolve => setTimeout(resolve, 100));

    const res = await request(app)
      .get('/api/security/alerts')
      .set('Authorization', `Bearer ${API_KEY}`);
    
    expect(res.statusCode).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0].type).toBe('MULTIPLE_FAILED_LOGINS');
  });
});
