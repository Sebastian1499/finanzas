from flask import Blueprint, request, jsonify
from database import get_conn
from middleware.authenticate import authenticate

profile_bp = Blueprint('profile', __name__)

profile_bp.before_request(authenticate)


# ── GET /api/profile ──────────────────────────────────────────────────────
@profile_bp.route('/', methods=['GET'])
def get_profile():
    with get_conn() as conn:
        user = conn.execute(
            'SELECT id, name, email, phone, birthdate, currency FROM users WHERE id = ?',
            (request.user_id,),
        ).fetchone()
    if not user:
        return jsonify({'error': 'Usuario no encontrado'}), 404
    return jsonify(dict(user))


# ── PUT /api/profile ──────────────────────────────────────────────────────
@profile_bp.route('/', methods=['PUT'])
def update_profile():
    data      = request.get_json() or {}
    name      = data.get('name')
    email     = data.get('email')
    phone     = data.get('phone')
    birthdate = data.get('birthdate')
    currency  = data.get('currency')

    with get_conn() as conn:
        conn.execute(
            """UPDATE users
               SET name      = COALESCE(?, name),
                   email     = COALESCE(?, email),
                   phone     = COALESCE(?, phone),
                   birthdate = COALESCE(?, birthdate),
                   currency  = COALESCE(?, currency)
               WHERE id = ?""",
            (name, email, phone, birthdate, currency, request.user_id),
        )
    return jsonify({'message': 'Perfil actualizado'})
