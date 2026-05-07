import os
import jwt
from functools import wraps
from flask import request, jsonify

JWT_SECRET = os.environ.get('JWT_SECRET', 'finanzas_secret_key_2024')


def authenticate(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Token no proporcionado'}), 401
        token = auth_header[7:]
        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
            request.user_id = payload['userId']
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token inválido o expirado'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Token inválido o expirado'}), 401
        return f(*args, **kwargs)
    return decorated
