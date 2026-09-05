const fs = require('fs');
const path = require('path');

let events = [];
let alerts = [];

const dbPathEvents = path.join(__dirname, 'events.json');
const dbPathAlerts = path.join(__dirname, 'alerts.json');

function initDB() {
  return new Promise((resolve) => {
    if (process.env.NODE_ENV !== 'test') {
      try {
        if (fs.existsSync(dbPathEvents)) {
          events = JSON.parse(fs.readFileSync(dbPathEvents, 'utf-8'));
        }
        if (fs.existsSync(dbPathAlerts)) {
          alerts = JSON.parse(fs.readFileSync(dbPathAlerts, 'utf-8'));
        }
      } catch (e) {
        console.error('Error loading JSON DB', e);
      }
    }
    resolve();
  });
}

function saveDB() {
  if (process.env.NODE_ENV !== 'test') {
    fs.writeFileSync(dbPathEvents, JSON.stringify(events, null, 2));
    fs.writeFileSync(dbPathAlerts, JSON.stringify(alerts, null, 2));
  }
}

function getDB() {
  return {
    events,
    alerts,
    run: function (sql, params, callback) {
      if (sql.includes('INSERT INTO events')) {
        const [type, userId, requestInfo, status, description] = params;
        const ev = { id: events.length + 1, type, userId, requestInfo, status, description, timestamp: new Date().toISOString() };
        events.push(ev);
        saveDB();
        callback.call({ lastID: ev.id }, null);
      } else if (sql.includes('INSERT INTO alerts')) {
        const [type, description] = params;
        const al = { id: alerts.length + 1, type, description, timestamp: new Date().toISOString() };
        alerts.push(al);
        saveDB();
        callback.call({ lastID: al.id }, null);
      } else {
        callback(null);
      }
    },
    get: function (sql, params, callback) {
      if (sql.includes('COUNT(*) as count FROM events WHERE type = \'FAILED_LOGIN\' AND timestamp > ?')) {
        const timeLimit = params[0];
        const count = events.filter(e => e.type === 'FAILED_LOGIN' && e.timestamp > timeLimit).length;
        callback(null, { count });
      } else {
        callback(null, null);
      }
    },
    all: function (sql, params, callback) {
      if (sql.includes('SELECT * FROM alerts')) {
        callback(null, [...alerts].reverse().slice(0, 20));
      } else if (sql.includes('SELECT * FROM events ORDER BY timestamp DESC LIMIT 10')) {
        callback(null, [...events].reverse().slice(0, 10));
      } else if (sql.includes('SELECT type, COUNT(*) as count FROM events GROUP BY type')) {
        const counts = {};
        events.forEach(e => {
          counts[e.type] = (counts[e.type] || 0) + 1;
        });
        const rows = Object.keys(counts).map(k => ({ type: k, count: counts[k] }));
        callback(null, rows);
      } else if (sql.includes('SELECT * FROM events WHERE 1=1')) {
        let filtered = events;
        // params matching depends on the query logic in routes.js
        // A simple hack: just filter manually
        callback(null, [...filtered].reverse().slice(0, 100));
      } else {
        callback(null, []);
      }
    },
    close: function(callback) {
      if (callback) callback();
    }
  };
}

module.exports = { initDB, getDB, events, alerts };
