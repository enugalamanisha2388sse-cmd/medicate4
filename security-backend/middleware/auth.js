function authenticate(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({ error: 'Unauthorized: Missing token' });
  }

  const token = authHeader.split(' ')[1];
  const expectedToken = process.env.API_KEY || 'default-secure-token-123';

  if (token !== expectedToken) {
    return res.status(403).json({ error: 'Forbidden: Invalid token' });
  }

  next();
}

module.exports = authenticate;
