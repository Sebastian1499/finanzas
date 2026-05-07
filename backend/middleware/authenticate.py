# Decorador de autenticación JWT.
# Cualquier ruta que lo use exige que el cliente mande un token válido
# en el header: Authorization: Bearer <token>
# Si el token es válido, el user_id queda disponible en request.user_id
# para que la ruta sepa a qué usuario pertenece la petición.

import os
import jwt
from functools import wraps
from flask import request, jsonify

# La clave secreta se puede cambiar por variable de entorno en producción.
JWT_SECRET = os.environ.get('JWT_SECRET', 'finanzas_secret_key_2024')


def authenticate(f):
    """Decorador que verifica el token JWT antes de ejecutar la vista."""
    @wraps(f)
    def decorated(*args, **kwargs):
        # Esperamos el header en formato: 'Bearer eyJ...'
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Token no proporcionado'}), 401

        token = auth_header[7:]  # quitar el prefijo 'Bearer '
        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
            # Guardamos el ID en el objeto request para que la ruta lo use
            request.user_id = payload['userId']
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token inválido o expirado'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token inválido o expirado'}), 401

        return f(*args, **kwargs)
    return decorated
