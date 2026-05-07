# Estadísticas financieras del usuario.
# Es el único endpoint que no hace CRUD sino que agrega datos
# para mostrar resúmenes en la pantalla de estadísticas de la app.

from flask import Blueprint, request, jsonify
from database import get_conn
from middleware.authenticate import authenticate

stats_bp = Blueprint('stats', __name__)

stats_bp.before_request(authenticate)


# GET /api/stats
# Devuelve un resumen financiero completo:
#   - totalIngresos: suma de todas las transacciones de tipo ingreso
#   - totalEgresos:  suma de todas las transacciones de tipo egreso
#   - saldo:         totalIngresos - totalEgresos
#   - breakdown:     lista agrupada por etiqueta con el total de cada una
@stats_bp.route('/', methods=['GET'])
def get_stats():
    with get_conn() as conn:
        # Agrupamos por etiqueta y tipo (ingreso/egreso) para el breakdown
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
        total     = float(r['total'])
        is_income = bool(r['is_income'])

        # Acumulamos los totales globales mientras construimos el breakdown
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
