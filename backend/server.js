const express = require('express');
const cors    = require('cors');
const { init } = require('./database');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middlewares ────────────────────────────────────────────────────────────
app.use(cors());          // Permite peticiones desde Flutter Web (localhost:8080)
app.use(express.json());  // Parsear body JSON

// ── Rutas ──────────────────────────────────────────────────────────────────
app.use('/api/auth',         require('./routes/auth'));
app.use('/api/transactions', require('./routes/transactions'));
app.use('/api/labels',       require('./routes/labels'));
app.use('/api/profile',      require('./routes/profile'));

// ── Iniciar servidor ───────────────────────────────────────────────────────
init()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`API corriendo en http://localhost:${PORT}/api`);
    });
  })
  .catch(err => {
    console.error('Error al inicializar la base de datos:', err);
    process.exit(1);
  });
