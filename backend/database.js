const sqlite3 = require('sqlite3').verbose();
const path    = require('path');

const db = new sqlite3.Database(path.join(__dirname, 'finanzas.db'));

// ── Helpers para usar Promises en lugar de callbacks ──────────────────────
const run = (sql, params = []) =>
  new Promise((resolve, reject) =>
    db.run(sql, params, function (err) {
      if (err) reject(err);
      else resolve(this);          // `this.lastID` y `this.changes` disponibles
    })
  );

const get = (sql, params = []) =>
  new Promise((resolve, reject) =>
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    })
  );

const all = (sql, params = []) =>
  new Promise((resolve, reject) =>
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    })
  );

// ── Crear tablas al arrancar ───────────────────────────────────────────────
async function init() {
  await run(`
    CREATE TABLE IF NOT EXISTS users (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      name       TEXT    NOT NULL,
      email      TEXT    UNIQUE NOT NULL,
      password   TEXT    NOT NULL,
      phone      TEXT    DEFAULT '',
      birthdate  TEXT    DEFAULT '',
      currency   TEXT    DEFAULT 'COP',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS transactions (
      id         TEXT    PRIMARY KEY,
      user_id    INTEGER NOT NULL,
      label      TEXT    NOT NULL,
      amount     REAL    NOT NULL,
      is_income  INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS labels (
      id         TEXT    PRIMARY KEY,
      user_id    INTEGER NOT NULL,
      name       TEXT    NOT NULL,
      color      INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  `);
}

module.exports = { run, get, all, init };
