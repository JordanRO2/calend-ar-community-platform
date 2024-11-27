# relative path: app/infrastructure/websockets/socketio.py

from flask_socketio import SocketIO
from app.core.config import Config  # Importar la configuración

# Configuración de SocketIO con Redis como backend de mensajes
socketio = SocketIO(
    message_queue=Config.REDIS_URL,  # Obtener la URL de Redis desde la configuración
    cors_allowed_origins="*"  # Permitir CORS desde cualquier origen
)
