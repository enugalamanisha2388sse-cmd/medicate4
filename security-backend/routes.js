const express = require('express');
const { body, validationResult } = require('express-validator');
const { getDB } = require('./database');
const { processAlertRules } = require('./alert-rules');
const authenticate = require('./middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// Log a security event
router.post(
  '/events',
  [
    body('type').isString().notEmpty(),
    body('userId').optional().isString(),
    body('requestInfo').optional().isString(),
    body('status').optional().isString(),
    body('description').optional().isString(),
  ],
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { type, userId, requestInfo, status, description } = req.body;
    const db = getDB();

    db.run(
      `INSERT INTO events (type, userId, requestInfo, status, description) VALUES (?, ?, ?, ?, ?)`,
      [type, userId, requestInfo, status, description],
      function (err) {
        if (err) {
          console.error(err);
          return res.status(500).json({ error: 'Database error' });
        }
        
        const newEvent = { id: this.lastID, type, userId, requestInfo, status, description };
        processAlertRules(newEvent);
        
        res.status(201).json(newEvent);
      }
    );
  }
);

// Get security events with optional filtering
router.get('/events', (req, res) => {
  const { type, startDate, endDate } = req.query;
  const db = getDB();
  db.all('SELECT * FROM events WHERE 1=1', [], (err, rows) => {
    let filtered = rows;
    if (type) filtered = filtered.filter(e => e.type === type);
    if (startDate) filtered = filtered.filter(e => e.timestamp >= startDate);
    if (endDate) filtered = filtered.filter(e => e.timestamp <= endDate);
    res.json(filtered);
  });
});

// Get recent events (for dashboard)
router.get('/events/recent', (req, res) => {
  const db = getDB();
  db.all(`SELECT * FROM events ORDER BY timestamp DESC LIMIT 10`, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    res.json(rows);
  });
});

// Get security alerts
router.get('/alerts', (req, res) => {
  const db = getDB();
  db.all(`SELECT * FROM alerts ORDER BY timestamp DESC LIMIT 20`, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    res.json(rows);
  });
});

// Get event statistics
router.get('/stats', (req, res) => {
  const db = getDB();
  const stats = {
    totalEvents: 0,
    successfulLogins: 0,
    failedLogins: 0,
    unauthorizedRequests: 0,
  };

  db.all(`SELECT type, COUNT(*) as count FROM events GROUP BY type`, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    rows.forEach(row => {
      stats.totalEvents += row.count;
      if (row.type === 'SUCCESSFUL_LOGIN') stats.successfulLogins += row.count;
      if (row.type === 'FAILED_LOGIN') stats.failedLogins += row.count;
      if (row.type === 'UNAUTHORIZED_ACCESS') stats.unauthorizedRequests += row.count;
    });

    res.json(stats);
  });
});

module.exports = router;
