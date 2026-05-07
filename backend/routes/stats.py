from flask import Blueprint, request, jsonify
from database import get_conn
from middleware.authenticate import authenticate

stats_bp = Blueprint('stats', __name__)

stats_bp.before_request(authenticate)


# ── GET /api/stats ────────────────────────────────────────────────────────
# Devuelve un resumen financiero del usuario:
# - total_ingresos, total_egresos, saldo
# - breakdown: lista de { label, total, isIncome } agrupado por etiqueta
@stats_bp.route('/', methods=['GET'])
def get_stats():
    with get_conn() as conn:
        rows = conn.execute(
            """SELECT label, is_income, SUM(amount) as total
               FROM transactions
               WHERE user_id = ?
               GROUP BY label, is_income
               ORDER BY total DESC""",
            (request.user_id,),
        ).fetchall()

    total_ingresos = 0.0
    total_egresos  = 0.0
    breakdown      = []

    for r in rows:
        total = float(r['total'])
        is_income = bool(r['is_income'])
        if is_income:
            total_ingresos += total
        else:
            total_egresos += total
        breakdown.append({
            'label':    r['label'],
            'total':    total,
            'isIncome': is_income,
        })

    return jsonify({
        'totalIngresos': total_ingresos,
        'totalEgresos':  total_egresos,
        'saldo':         total_ingresos - total_egresos,
        'breakdown':     breakdown,
    })
