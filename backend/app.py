import os
from flask import Flask
from flask_cors import CORS
from database import init_db
from routes.auth         import auth_bp
from routes.transactions import transactions_bp
from routes.labels       import labels_bp
from routes.profile      import profile_bp
from routes.stats        import stats_bp

app = Flask(__name__)
CORS(app)

# ── Registrar blueprints ───────────────────────────────────────────────────
app.register_blueprint(auth_bp,         url_prefix='/api/auth')
app.register_blueprint(transactions_bp, url_prefix='/api/transactions')
app.register_blueprint(labels_bp,       url_prefix='/api/labels')
app.register_blueprint(profile_bp,      url_prefix='/api/profile')
app.register_blueprint(stats_bp,        url_prefix='/api/stats')

if __name__ == '__main__':
    init_db()
    port = int(os.environ.get('PORT', 3000))
    print(f'API corriendo en http://localhost:{port}/api')
    app.run(host='0.0.0.0', port=port, debug=False)
