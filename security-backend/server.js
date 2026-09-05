require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const routes = require('./routes');
const { initDB } = require('./database');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.use('/api/security', routes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

async function startServer() {
  await initDB();
  app.listen(PORT, () => {
    console.log(`Security Monitoring API running on port ${PORT}`);
  });
}

if (require.main === module) {
  startServer();
}

module.exports = app;
