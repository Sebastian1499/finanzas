from flask import Blueprint, request, jsonify
from database import get_conn
from middleware.authenticate import authenticate

transactions_bp = Blueprint('transactions', __name__)

# Todas las rutas requieren autenticación
transactions_bp.before_request(authenticate)


def _fmt(row) -> dict:
    return {
        'id':        row['id'],
        'label':     row['label'],
        'amount':    row['amount'],
        'isIncome':  bool(row['is_income']),
        'createdAt': row['created_at'],
    }


# ── GET /api/transactions ─────────────────────────────────────────────────
@transactions_bp.route('/', methods=['GET'])
def get_transactions():
    with get_conn() as conn:
        rows = conn.execute(
            'SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC',
            (request.user_id,),
        ).fetchall()
    return jsonify([_fmt(r) for r in rows])


# ── POST /api/transactions ────────────────────────────────────────────────
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
        row = conn.execute('SELECT * FROM transactions WHERE id = ?', (tx_id,)).fetchone()
    return jsonify(_fmt(row)), 201


# ── PUT /api/transactions/:id ─────────────────────────────────────────────
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


# ── DELETE /api/transactions/:id ──────────────────────────────────────────
@transactions_bp.route('/<tx_id>', methods=['DELETE'])
def delete_transaction(tx_id):
    with get_conn() as conn:
        conn.execute(
            'DELETE FROM transactions WHERE id = ? AND user_id = ?',
            (tx_id, request.user_id),
        )
    return jsonify({'message': 'Transacción eliminada'})
