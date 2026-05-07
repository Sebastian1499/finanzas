import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'finanzas.db')


def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute('PRAGMA foreign_keys = ON')
    return conn


def init_db():
    with get_conn() as conn:
        conn.executescript("""
            CREATE TABLE IF NOT EXISTS users (
                id         INTEGER PRIMARY KEY AUTOINCREMENT,
                name       TEXT    NOT NULL,
                email      TEXT    UNIQUE NOT NULL,
                password   TEXT    NOT NULL,
                phone      TEXT    DEFAULT '',
                birthdate  TEXT    DEFAULT '',
                currency   TEXT    DEFAULT 'COP',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE IF NOT EXISTS transactions (
                id         TEXT    PRIMARY KEY,
                user_id    INTEGER NOT NULL,
                label      TEXT    NOT NULL,
                amount     REAL    NOT NULL,
                is_income  INTEGER NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            );

            CREATE TABLE IF NOT EXISTS labels (
                id         TEXT    PRIMARY KEY,
                user_id    INTEGER NOT NULL,
                name       TEXT    NOT NULL,
                color      INTEGER NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users (id)
            );
        """)
    print('Base de datos inicializada')
