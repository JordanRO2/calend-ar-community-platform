from datetime import timedelta

class Config:
    JWT_SECRET_KEY = "13de7913f96a009d62fa3ad141aed5b6d775b637ae5ac6e8399bdd4de963e3e1"
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1)
    MONGO_URI = "mongodb://mongo:27017/community_calendar"  # Cambiar localhost por mongo
    SOCKETIO_CORS_ALLOWED_ORIGINS = "*"
