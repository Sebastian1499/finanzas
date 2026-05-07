# Manejo de la base de datos SQLite.
# get_conn() abre una conexión lista para usar con context manager (with).
# init_db() crea las tablas la primera vez que se arranca el servidor.

import sqlite3
import os

# La base de datos vive en la misma carpeta que este archivo.
DB_PATH = os.path.join(os.path.dirname(__file__), 'finanzas.db')


def get_conn():
    """Devuelve una conexión SQLite con row_factory activado.
    Usar siempre con 'with' para que los cambios se commiten automáticamente.
    """
    conn = sqlite3.connect(DB_PATH)
    # row_factory permite acceder a las columnas por nombre: row['email']
    conn.row_factory = sqlite3.Row
    # Activamos claves foráneas porque SQLite las ignora por defecto
    conn.execute('PRAGMA foreign_keys = ON')
    return conn


def init_db():
    """Crea las tablas si todavía no existen. Se llama una sola vez al iniciar."""
    with get_conn() as conn:
        conn.executescript("""
            CREATE TABLE IF NOT EXISTS users (
                id         INTEGER PRIMARY KEY AUTOINCREMENT,
                name       TEXT    NOT NULL,
                email      TEXT    UNIQUE NOT NULL,
                password   TEXT    NOT NULL,  -- guardado como hash bcrypt, nunca en claro
                phone      TEXT    DEFAULT '',
                birthdate  TEXT    DEFAULT '',
                currency   TEXT    DEFAULT 'COP',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS transactions (
                id         TEXT    PRIMARY KEY,   -- ID generado desde Flutter (hex aleatorio)
                user_id    INTEGER NOT NULL,
                label      TEXT    NOT NULL,      -- nombre de la etiqueta en el momento del registro
                amount     REAL    NOT NULL,
                is_income  INTEGER NOT NULL,      -- 1 = ingreso, 0 = egreso
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            );

            CREATE TABLE IF NOT EXISTS labels (
                id         TEXT    PRIMARY KEY,   -- ID generado desde Flutter (lbl_hex)
                user_id    INTEGER NOT NULL,
                name       TEXT    NOT NULL,
                color      INTEGER NOT NULL,      -- valor ARGB como entero, ej: 0xFFEF5350
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            );
        """)
    print('Base de datos inicializada')
