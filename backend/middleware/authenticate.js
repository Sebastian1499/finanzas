const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'finanzas_secret_key_2024';

/**
 * Middleware que verifica el JWT del header Authorization.
 * Si es válido, agrega `req.userId` con el ID del usuario.
 */
function authenticate(req, res, next) {
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token no proporcionado' });
  }

  const token = authHeader.substring(7);

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch {
    res.status(401).json({ error: 'Token inválido o expirado' });
  }
}

module.exports = authenticate;
