# Rutas de autenticación: registro, login y cambio de contraseña.
# El registro crea el usuario y le genera 8 etiquetas por defecto
# para que la app no quede vacía desde el primer día.

import os
import random
import string
from datetime import datetime, timezone, timedelta

import bcrypt
import jwt
from flask import Blueprint, request, jsonify

from database import get_conn
from middleware.authenticate import authenticate

auth_bp = Blueprint('auth', __name__)

JWT_SECRET = os.environ.get('JWT_SECRET', 'finanzas_secret_key_2024')

# Etiquetas que se crean automáticamente cuando alguien se registra.
# Los colores son valores ARGB que Flutter entiende directamente.
DEFAULT_LABELS = [
    {'name': 'Alimentación',    'color': 0xFFEF5350},
    {'name': 'Transporte',      'color': 0xFF42A5F5},
    {'name': 'Salario',         'color': 0xFF66BB6A},
    {'name': 'Entretenimiento', 'color': 0xFFAB47BC},
    {'name': 'Salud',           'color': 0xFF26C6DA},
    {'name': 'Servicios',       'color': 0xFFFF7043},
    {'name': 'Educación',       'color': 0xFF8D6E63},
    {'name': 'Ahorro',          'color': 0xFF78909C},
]


def _make_token(user_id: int) -> str:
    """Genera un token JWT con 30 días de vigencia."""
    payload = {
        'userId': user_id,
        'exp': datetime.now(tz=timezone.utc) + timedelta(days=30),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm='HS256')


def _rand_id(prefix='lbl') -> str:
    """Genera un ID único con prefijo, por ejemplo: lbl_3a9f1b2c..."""
    chars = ''.join(random.choices(string.hexdigits[:16], k=16))
    return f'{prefix}_{chars}'


# POST /api/auth/register
# Crea una cuenta nueva. Valida que el correo no esté duplicado,
# hashea la contraseña con bcrypt y crea las etiquetas por defecto.
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    name     = (data.get('name') or '').strip()
    email    = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''

    if not name or not email or not password:
        return jsonify({'error': 'Nombre, correo y contraseña son requeridos'}), 400

    with get_conn() as conn:
        # No permitimos dos cuentas con el mismo correo
        if conn.execute('SELECT id FROM users WHERE email = ?', (email,)).fetchone():
            return jsonify({'error': 'Este correo ya está registrado'}), 409

        hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
        cursor = conn.execute(
            'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
            (name, email, hashed),
        )
        user_id = cursor.lastrowid

        # Creamos las etiquetas iniciales para que la app no quede vacía
        for lbl in DEFAULT_LABELS:
            conn.execute(
                'INSERT INTO labels (id, user_id, name, color) VALUES (?, ?, ?, ?)',
                (_rand_id('lbl'), user_id, lbl['name'], lbl['color']),
            )

    token = _make_token(user_id)
    return jsonify({'token': token, 'userId': user_id, 'name': name, 'email': email}), 201


# POST /api/auth/login
# Verifica las credenciales y devuelve un token JWT si son correctas.
@auth_bp.route('/login', methods=['POST'])
def login():
    data     = request.get_json() or {}
    email    = (data.get('email') or '').strip().lower()
    password = data.get('password') or ''

    if not email or not password:
        return jsonify({'error': 'Correo y contraseña son requeridos'}), 400

    with get_conn() as conn:
        user = conn.execute('SELECT * FROM users WHERE email = ?', (email,)).fetchone()

    if not user:
        return jsonify({'error': 'Correo no registrado. ¿Aún no tienes cuenta?'}), 401

    # bcrypt.checkpw compara el texto plano con el hash guardado
    if not bcrypt.checkpw(password.encode(), user['password'].encode()):
        return jsonify({'error': 'Correo o contraseña incorrectos'}), 401

    token = _make_token(user['id'])
    return jsonify({'token': token, 'userId': user['id'], 'name': user['name'], 'email': user['email']})


# PUT /api/auth/change-password  (requiere token)
# El usuario debe mandar su contraseña actual como verificación
# antes de poder cambiarla por una nueva.
@auth_bp.route('/change-password', methods=['PUT'])
@authenticate
def change_password():
    data             = request.get_json() or {}
    current_password = data.get('currentPassword') or ''
    new_password     = data.get('newPassword') or ''

    if not current_password or not new_password:
        return jsonify({'error': 'Contraseña actual y nueva son requeridas'}), 400

    if len(new_password) < 6:
        return jsonify({'error': 'La contraseña debe tener al menos 6 caracteres'}), 400

    with get_conn() as conn:
        user = conn.execute('SELECT * FROM users WHERE id = ?', (request.user_id,)).fetchone()
        if not user:
            return jsonify({'error': 'Usuario no encontrado'}), 404

        # Verificamos la contraseña actual antes de permitir el cambio
        if not bcrypt.checkpw(current_password.encode(), user['password'].encode()):
            return jsonify({'error': 'La contraseña actual es incorrecta'}), 401

        hashed = bcrypt.hashpw(new_password.encode(), bcrypt.gensalt()).decode()
        conn.execute('UPDATE users SET password = ? WHERE id = ?', (hashed, request.user_id))

    return jsonify({'message': 'Contraseña actualizada correctamente'})
