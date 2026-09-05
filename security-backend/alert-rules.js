const { getDB } = require('./database');

async function processAlertRules(event) {
  if (event.type === 'FAILED_LOGIN') {
    const db = getDB();
    const timeLimit = new Date(Date.now() - 5 * 60 * 1000).toISOString(); // last 5 minutes
    
    db.get(
      `SELECT COUNT(*) as count FROM events WHERE type = 'FAILED_LOGIN' AND timestamp > ?`,
      [timeLimit],
      (err, row) => {
        if (err) {
          console.error('Error checking alert rules:', err);
          return;
        }
        
        if (row && row.count >= 5) {
          // Generate alert
          db.run(
            `INSERT INTO alerts (type, description) VALUES (?, ?)`,
            ['MULTIPLE_FAILED_LOGINS', 'Multiple failed login attempts detected in a short period.'],
            (err) => {
              if (err) console.error('Error saving alert:', err);
            }
          );
        }
      }
    );
  }
}

module.exports = { processAlertRules };
