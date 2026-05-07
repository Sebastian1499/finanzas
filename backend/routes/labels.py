# CRUD de etiquetas (categorías de gastos/ingresos).
# Las etiquetas son personales: cada usuario tiene las suyas.
# Se ordenan por fecha de creación para que las predeterminadas
# siempre aparezcan primero en la app.

from flask import Blueprint, request, jsonify
from database import get_conn
from middleware.authenticate import authenticate

labels_bp = Blueprint('labels', __name__)

# Todas las rutas de etiquetas requieren estar autenticado
labels_bp.before_request(authenticate)


# GET /api/labels
# Lista todas las etiquetas del usuario en orden de creación.
@labels_bp.route('/', methods=['GET'])
def get_labels():
    with get_conn() as conn:
        rows = conn.execute(
            'SELECT * FROM labels WHERE user_id = ? ORDER BY created_at',
            (request.user_id,),
        ).fetchall()
    return jsonify([{'id': r['id'], 'name': r['name'], 'color': r['color']} for r in rows])


# POST /api/labels
# Crea una etiqueta nueva. El ID y el color vienen desde Flutter
# (el color es un entero ARGB, ej: 0xFFEF5350 para rojo).
@labels_bp.route('/', methods=['POST'])
def add_label():
    data   = request.get_json() or {}
    lbl_id = data.get('id')
    name   = data.get('name')
    color  = data.get('color')

    if not lbl_id or not name or color is None:
        return jsonify({'error': 'Datos incompletos'}), 400

    with get_conn() as conn:
        conn.execute(
            'INSERT INTO labels (id, user_id, name, color) VALUES (?, ?, ?, ?)',
            (lbl_id, request.user_id, name, color),
        )
    return jsonify({'id': lbl_id, 'name': name, 'color': color}), 201


# PUT /api/labels/<lbl_id>
# Cambia el nombre y/o color de una etiqueta.
# Validamos que sea del usuario antes de modificar.
@labels_bp.route('/<lbl_id>', methods=['PUT'])
def update_label(lbl_id):
    data  = request.get_json() or {}
    name  = data.get('name')
    color = data.get('color')

    with get_conn() as conn:
        row = conn.execute(
            'SELECT id FROM labels WHERE id = ? AND user_id = ?',
            (lbl_id, request.user_id),
        ).fetchone()
        if not row:
            return jsonify({'error': 'Etiqueta no encontrada'}), 404

        conn.execute(
            'UPDATE labels SET name = ?, color = ? WHERE id = ? AND user_id = ?',
            (name, color, lbl_id, request.user_id),
        )
    return jsonify({'id': lbl_id, 'name': name, 'color': color})


# DELETE /api/labels/<lbl_id>
# Elimina la etiqueta. Las transacciones que la usaban conservan
# el nombre como texto (no hay FK entre transactions y labels).
@labels_bp.route('/<lbl_id>', methods=['DELETE'])
def delete_label(lbl_id):
    with get_conn() as conn:
        conn.execute(
            'DELETE FROM labels WHERE id = ? AND user_id = ?',
            (lbl_id, request.user_id),
        )
    return jsonify({'message': 'Etiqueta eliminada'})
