const express      = require('express');
const router       = express.Router();
const { run, get } = require('../database');
const authenticate = require('../middleware/authenticate');

router.use(authenticate);

// ── GET /api/profile ──────────────────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const user = await get(
      'SELECT id, name, email, phone, birthdate, currency FROM users WHERE id = ?',
      [req.userId]
    );
    if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener perfil' });
  }
});

// ── PUT /api/profile ──────────────────────────────────────────────────────
router.put('/', async (req, res) => {
  const { name, phone, birthdate, currency, email } = req.body;

  try {
    await run(
      `UPDATE users
       SET name      = COALESCE(?, name),
           email     = COALESCE(?, email),
           phone     = COALESCE(?, phone),
           birthdate = COALESCE(?, birthdate),
           currency  = COALESCE(?, currency)
       WHERE id = ?`,
      [
        name      ?? null,
        email     ?? null,
        phone     ?? null,
        birthdate ?? null,
        currency  ?? null,
        req.userId,
      ]
    );
    res.json({ message: 'Perfil actualizado' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar perfil' });
  }
});

module.exports = router;
