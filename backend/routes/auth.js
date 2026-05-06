const express  = require('express');
const router   = express.Router();
const bcrypt   = require('bcryptjs');
const jwt      = require('jsonwebtoken');
const { run, get } = require('../database');
const authenticate = require('../middleware/authenticate');

const JWT_SECRET = process.env.JWT_SECRET || 'finanzas_secret_key_2024';

// Etiquetas que se crean automáticamente al registrarse
const DEFAULT_LABELS = [
  { name: 'Alimentación',    color: 0xFFEF5350 },
  { name: 'Transporte',      color: 0xFF42A5F5 },
  { name: 'Salario',         color: 0xFF66BB6A },
  { name: 'Entretenimiento', color: 0xFFAB47BC },
  { name: 'Salud',           color: 0xFF26C6DA },
  { name: 'Servicios',       color: 0xFFFF7043 },
  { name: 'Educación',       color: 0xFF8D6E63 },
  { name: 'Ahorro',          color: 0xFF78909C },
];

// ── POST /api/auth/register ────────────────────────────────────────────────
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Nombre, correo y contraseña son requeridos' });
  }

  try {
    const existing = await get('SELECT id FROM users WHERE email = ?', [
      email.toLowerCase().trim(),
    ]);
    if (existing) {
      return res.status(409).json({ error: 'Este correo ya está registrado' });
    }

    const hashed = await bcrypt.hash(password, 10);
    const result = await run(
      'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
      [name.trim(), email.toLowerCase().trim(), hashed]
    );

    const userId = result.lastID;

    // Crear etiquetas por defecto
    for (const label of DEFAULT_LABELS) {
      const id = `lbl_${userId}_${Date.now()}_${Math.random().toString(36).slice(2)}`;
      await run(
        'INSERT INTO labels (id, user_id, name, color) VALUES (?, ?, ?, ?)',
        [id, userId, label.name, label.color]
      );
    }

    const token = jwt.sign({ userId }, JWT_SECRET, { expiresIn: '30d' });
    res.status(201).json({
      token,
      userId,
      name: name.trim(),
      email: email.toLowerCase().trim(),
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al registrar usuario' });
  }
});

// ── POST /api/auth/login ───────────────────────────────────────────────────
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Correo y contraseña son requeridos' });
  }

  try {
    const user = await get('SELECT * FROM users WHERE email = ?', [
      email.toLowerCase().trim(),
    ]);
    if (!user) {
      return res.status(401).json({ error: 'Correo no registrado. ¿Aún no tienes cuenta?' });
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
    }

    const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, userId: user.id, name: user.name, email: user.email });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

// ── PUT /api/auth/change-password ─────────────────────────────────────────
router.put('/change-password', authenticate, async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ error: 'Contraseña actual y nueva son requeridas' });
  }

  try {
    const user = await get('SELECT * FROM users WHERE id = ?', [req.userId]);
    if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });

    const valid = await bcrypt.compare(currentPassword, user.password);
    if (!valid) {
      return res.status(401).json({ error: 'La contraseña actual es incorrecta' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    await run('UPDATE users SET password = ? WHERE id = ?', [hashed, req.userId]);
    res.json({ message: 'Contraseña actualizada correctamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al cambiar contraseña' });
  }
});

module.exports = router;
