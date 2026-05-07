# CRUD de transacciones. Todas las rutas requieren token válido.
# El usuario solo puede ver y modificar sus propias transacciones;
# el filtro WHERE user_id = ? lo garantiza en cada consulta.

from flask import Blueprint, request, jsonify
from database import get_conn
from middleware.authenticate import authenticate

transactions_bp = Blueprint('transactions', __name__)

# Aplicamos el decorador a todas las rutas de este blueprint de una vez
transactions_bp.before_request(authenticate)


def _fmt(row) -> dict:
    """Convierte una fila de SQLite al formato JSON que espera Flutter.
    is_income se guarda como 0/1 en la BD pero Flutter lo necesita como bool.
    """
    return {
        'id':        row['id'],
        'label':     row['label'],
        'amount':    row['amount'],
        'isIncome':  bool(row['is_income']),
        'createdAt': row['created_at'],
    }


# GET /api/transactions
# Devuelve todas las transacciones del usuario, de más reciente a más antigua.
@transactions_bp.route('/', methods=['GET'])
def get_transactions():
    with get_conn() as conn:
        rows = conn.execute(
            'SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC',
            (request.user_id,),
        ).fetchall()
    return jsonify([_fmt(r) for r in rows])


# POST /api/transactions
# Crea una nueva transacción. El ID lo genera Flutter para evitar conflictos
# cuando se trabaja offline y se sincroniza después.
@transactions_bp.route('/', methods=['POST'])
def add_transaction():
    data      = request.get_json() or {}
    tx_id     = data.get('id')
    label     = data.get('label')
    amount    = data.get('amount')
    is_income = data.get('isIncome')

    if not tx_id or not label or amount is None or is_income is None:
        return jsonify({'error': 'Datos incompletos'}), 400

    with get_conn() as conn:
        conn.execute(
            'INSERT INTO transactions (id, user_id, label, amount, is_income) VALUES (?, ?, ?, ?, ?)',
            (tx_id, request.user_id, label, amount, 1 if is_income else 0),
        )
        # Devolvemos la fila recién creada para que Flutter tenga el created_at real
        row = conn.execute('SELECT * FROM transactions WHERE id = ?', (tx_id,)).fetchone()
    return jsonify(_fmt(row)), 201


# PUT /api/transactions/<tx_id>
# Actualiza la etiqueta y el monto de una transacción existente.
# Verificamos que el ID pertenezca al usuario antes de modificar.
@transactions_bp.route('/<tx_id>', methods=['PUT'])
def update_transaction(tx_id):
    data   = request.get_json() or {}
    label  = data.get('label')
    amount = data.get('amount')

    with get_conn() as conn:
        row = conn.execute(
            'SELECT id FROM transactions WHERE id = ? AND user_id = ?',
            (tx_id, request.user_id),
        ).fetchone()
        if not row:
            return jsonify({'error': 'Transacción no encontrada'}), 404

        conn.execute(
            'UPDATE transactions SET label = ?, amount = ? WHERE id = ? AND user_id = ?',
            (label, amount, tx_id, request.user_id),
        )
    return jsonify({'message': 'Transacción actualizada'})


# DELETE /api/transactions/<tx_id>
# Elimina una transacción. El doble filtro id + user_id evita que
# un usuario pueda borrar transacciones ajenas.
@transactions_bp.route('/<tx_id>', methods=['DELETE'])
def delete_transaction(tx_id):
    with get_conn() as conn:
        conn.execute(
            'DELETE FROM transactions WHERE id = ? AND user_id = ?',
            (tx_id, request.user_id),
        )
    return jsonify({'message': 'Transacción eliminada'})
