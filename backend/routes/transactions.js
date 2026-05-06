const express      = require('express');
const router       = express.Router();
const { run, get, all } = require('../database');
const authenticate = require('../middleware/authenticate');

// Todas las rutas requieren autenticación
router.use(authenticate);

// ── GET /api/transactions ─────────────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const rows = await all(
      'SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC',
      [req.userId]
    );
    res.json(
      rows.map(r => ({
        id:        r.id,
        label:     r.label,
        amount:    r.amount,
        isIncome:  r.is_income === 1,
        createdAt: r.created_at,
      }))
    );
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener transacciones' });
  }
});

// ── POST /api/transactions ────────────────────────────────────────────────
router.post('/', async (req, res) => {
  const { id, label, amount, isIncome } = req.body;

  if (!id || !label || amount == null || isIncome == null) {
    return res.status(400).json({ error: 'Datos incompletos' });
  }

  try {
    await run(
      'INSERT INTO transactions (id, user_id, label, amount, is_income) VALUES (?, ?, ?, ?, ?)',
      [id, req.userId, label, amount, isIncome ? 1 : 0]
    );
    const created = await get('SELECT * FROM transactions WHERE id = ?', [id]);
    res.status(201).json({
      id:        created.id,
      label:     created.label,
      amount:    created.amount,
      isIncome:  created.is_income === 1,
      createdAt: created.created_at,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear transacción' });
  }
});

// ── PUT /api/transactions/:id ─────────────────────────────────────────────
router.put('/:id', async (req, res) => {
  const { label, amount } = req.body;

  try {
    const tx = await get(
      'SELECT id FROM transactions WHERE id = ? AND user_id = ?',
      [req.params.id, req.userId]
    );
    if (!tx) return res.status(404).json({ error: 'Transacción no encontrada' });

    await run(
      'UPDATE transactions SET label = ?, amount = ? WHERE id = ? AND user_id = ?',
      [label, amount, req.params.id, req.userId]
    );
    res.json({ message: 'Transacción actualizada' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar transacción' });
  }
});

// ── DELETE /api/transactions/:id ──────────────────────────────────────────
router.delete('/:id', async (req, res) => {
  try {
    await run(
      'DELETE FROM transactions WHERE id = ? AND user_id = ?',
      [req.params.id, req.userId]
    );
    res.json({ message: 'Transacción eliminada' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al eliminar transacción' });
  }
});

module.exports = router;
