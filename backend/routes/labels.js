const express      = require('express');
const router       = express.Router();
const { run, get, all } = require('../database');
const authenticate = require('../middleware/authenticate');

router.use(authenticate);

// ── GET /api/labels ───────────────────────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const rows = await all(
      'SELECT * FROM labels WHERE user_id = ? ORDER BY created_at',
      [req.userId]
    );
    res.json(rows.map(r => ({ id: r.id, name: r.name, color: r.color })));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener etiquetas' });
  }
});

// ── POST /api/labels ──────────────────────────────────────────────────────
router.post('/', async (req, res) => {
  const { id, name, color } = req.body;

  if (!id || !name || color == null) {
    return res.status(400).json({ error: 'Datos incompletos' });
  }

  try {
    await run(
      'INSERT INTO labels (id, user_id, name, color) VALUES (?, ?, ?, ?)',
      [id, req.userId, name, color]
    );
    res.status(201).json({ id, name, color });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear etiqueta' });
  }
});

// ── PUT /api/labels/:id ───────────────────────────────────────────────────
router.put('/:id', async (req, res) => {
  const { name, color } = req.body;

  try {
    const label = await get(
      'SELECT id FROM labels WHERE id = ? AND user_id = ?',
      [req.params.id, req.userId]
    );
    if (!label) return res.status(404).json({ error: 'Etiqueta no encontrada' });

    await run(
      'UPDATE labels SET name = ?, color = ? WHERE id = ? AND user_id = ?',
      [name, color, req.params.id, req.userId]
    );
    res.json({ id: req.params.id, name, color });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar etiqueta' });
  }
});

// ── DELETE /api/labels/:id ────────────────────────────────────────────────
router.delete('/:id', async (req, res) => {
  try {
    await run(
      'DELETE FROM labels WHERE id = ? AND user_id = ?',
      [req.params.id, req.userId]
    );
    res.json({ message: 'Etiqueta eliminada' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al eliminar etiqueta' });
  }
});

module.exports = router;
