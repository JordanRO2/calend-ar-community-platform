from pymongo import MongoClient
from flask import current_app, g

# Global client (initialized in init_app)
client = None

def get_db():
    """Obtiene la instancia de la base de datos MongoDB."""
    global client
    if 'db' not in g:
        if client is None:
            MONGO_URI = current_app.config.get("MONGO_URI", "mongodb://localhost:27017/community_calendar")
            current_app.logger.info("Estableciendo nueva conexión a MongoDB")
            client = MongoClient(MONGO_URI)
        db_name = current_app.config.get("DB_NAME", "community_calendar")
        g.db = client[db_name]  # Store database in 'g'
    else:
        current_app.logger.info("Reutilizando conexión existente a MongoDB")

    current_app.logger.debug(f"MongoClient estado: {client}")
    return g.db

def close_db(e=None):
    """Cierra la conexión a la base de datos si existe."""
    db = g.pop('db', None)  # Remove 'db' from 'g'
    if db is not None:
        # We don't close the client here, as it's managed globally
        pass

def init_app(app):
    """Inicializa la aplicación Flask."""
    global client
    with app.app_context():
        MONGO_URI = current_app.config.get("MONGO_URI", "mongodb://localhost:27017/community_calendar")
        current_app.logger.info("Inicializando MongoClient")
        client = MongoClient(MONGO_URI)  # Initialize client globally
    app.teardown_appcontext(close_db)