import os
import eventlet
eventlet.monkey_patch()  # Parchear las bibliotecas necesarias para Redis y WebSocket

from flask import Flask
from flask_jwt_extended import JWTManager
from flask_cors import CORS  # Importar CORS
from app.core.config import config_by_name
from app.infrastructure.web.user_controller import user_controller
from app.infrastructure.web.reply_controller import reply_controller
from app.infrastructure.web.rating_controller import rating_controller
from app.infrastructure.web.notification_controller import notification_controller
from app.infrastructure.web.event_controller import event_controller
from app.infrastructure.web.community_controller import community_controller
from app.infrastructure.web.comment_controller import comment_controller
from app.infrastructure.web.calendar_controller import calendar_controller
from app.infrastructure.websockets.socketio import socketio  # Importar instancia de socketio
from app.infrastructure.cache.redis_client import redis_client  # Importar cliente Redis
from app.infrastructure.db import get_db_instance  # Importar tu método personalizado para conectarte a MongoDB


# Inicialización de la aplicación Flask
app = Flask(__name__)

# Habilitar CORS
CORS(app, resources={r"/*": {"origins": "*"}})

# Cargar la configuración según el entorno
config_name = os.getenv('FLASK_ENV', 'development')
app.config.from_object(config_by_name[config_name])

# Inicializar JWT Manager
jwt = JWTManager(app)

# Inicializar la base de datos MongoDB dentro del contexto de la aplicación
with app.app_context():
    db = get_db_instance()  # Ahora usas tu función personalizada de pymongo para conectarte a MongoDB

# Inicializar SocketIO y Redis
socketio.init_app(app, message_queue=app.config['REDIS_URL'], cors_allowed_origins="*")  # Inicializamos la app con socketio

# Registrar Blueprints (controladores)
app.register_blueprint(user_controller)
app.register_blueprint(reply_controller)
app.register_blueprint(rating_controller)
app.register_blueprint(notification_controller)
app.register_blueprint(event_controller)
app.register_blueprint(community_controller)
app.register_blueprint(comment_controller)
app.register_blueprint(calendar_controller)

# Evento de WebSocket de prueba para usar Redis como backend
@socketio.on('redis_test_event')
def handle_redis_test_event(data):
    print(f"Mensaje recibido: {data}")
    # Emitir respuesta a través de WebSocket utilizando Redis como backend
    socketio.emit('redis_response_event', {'message': 'Redis está funcionando correctamente'})

# Ruta de prueba para verificar que el servidor está funcionando
@app.route('/')
def index():
    return "¡Bienvenido a la Plataforma de Calendario Comunitario!"

# Iniciar la aplicación usando SocketIO con Redis como backend de mensajes
if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)
