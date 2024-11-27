# relative path: app/infrastructure/web/notification_controller.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.domain.notification.use_cases import NotificationUseCases
from app.infrastructure.db import get_db_instance  # Asume que get_db_instance devuelve una instancia de la base de datos
from app.infrastructure.cache.redis_client import redis_client  # Importar cliente Redis
from app.infrastructure.websockets.socketio import socketio  # Importar instancia de SocketIO
from bson import ObjectId
import json

notification_controller = Blueprint('notification_controller', __name__)

def serialize_doc(doc):
    """
    Recursively convierte ObjectId en strings dentro de un documento.
    """
    if isinstance(doc, list):
        return [serialize_doc(item) for item in doc]
    elif isinstance(doc, dict):
        new_doc = {}
        for key, value in doc.items():
            if isinstance(value, ObjectId):
                new_doc[key] = str(value)
            elif isinstance(value, dict) or isinstance(value, list):
                new_doc[key] = serialize_doc(value)
            else:
                new_doc[key] = value
        return new_doc
    else:
        return doc

# Ruta para crear una nueva notificación
@notification_controller.route('/api/notifications/create', methods=['POST'])
@jwt_required()
def create_notification():
    db = get_db_instance()
    notification_use_cases = NotificationUseCases(db)

    notification_data = request.get_json()
    notification_data['user_id'] = get_jwt_identity()  # Añade el ID del usuario autenticado

    # Crear la notificación
    result = notification_use_cases.create_notification(notification_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar el resultado
    serialized_result = serialize_doc(result)

    # Notificar a través de WebSocket
    # Asegurarse de que 'notification_id' es una cadena
    notification_id = str(result["_id"]) if isinstance(result.get("_id"), ObjectId) else result.get("_id")
    socketio.emit('notification_created', {'user_id': notification_data['user_id'], 'notification_id': notification_id})

    # Cachear la notificación en Redis
    serialized_notification = serialize_doc(notification_data)
    redis_client.set(f"notification:{notification_id}", json.dumps(serialized_notification))

    return jsonify({"message": "Notificación creada exitosamente", "notification_id": notification_id}), 201

# Ruta para marcar una notificación como leída
@notification_controller.route('/api/notifications/<notification_id>/mark-read', methods=['POST'])
@jwt_required()
def mark_notification_as_read(notification_id):
    db = get_db_instance()
    notification_use_cases = NotificationUseCases(db)

    # Marcar la notificación como leída
    result = notification_use_cases.mark_notification_as_read(notification_id)
    if result:
        # Actualizar estado en Redis
        updated_data = {'status': 'read'}
        serialized_updated_data = serialize_doc(updated_data)
        redis_client.set(f"notification:{notification_id}", json.dumps(serialized_updated_data))

        # Emitir a través de WebSocket que la notificación fue leída
        socketio.emit('notification_read', {"notification_id": notification_id})

        return jsonify({"message": "Notificación marcada como leída"}), 200

    return jsonify({"error": "Error al marcar la notificación como leída"}), 400

# Ruta para obtener los detalles de una notificación
@notification_controller.route('/api/notifications/<notification_id>', methods=['GET'])
@jwt_required()
def get_notification_details(notification_id):
    db = get_db_instance()
    notification_use_cases = NotificationUseCases(db)

    # Buscar en Redis primero
    cached_notification = redis_client.get(f"notification:{notification_id}")
    if cached_notification:
        try:
            notification = json.loads(cached_notification)
            return jsonify(notification), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a buscar en la base de datos

    # Si no está en Redis, buscar en la base de datos
    notification = notification_use_cases.get_notification_details(notification_id)
    if not notification:
        return jsonify({"error": "Notificación no encontrada"}), 404

    # Serializar el documento
    serialized_notification = serialize_doc(notification)

    # Cachear el resultado en Redis para la próxima vez
    redis_client.set(f"notification:{notification_id}", json.dumps(serialized_notification))

    return jsonify(serialized_notification), 200

# Ruta para listar las notificaciones de un usuario con paginación
@notification_controller.route('/api/notifications/user/<user_id>', methods=['GET'])
@jwt_required()
def list_user_notifications(user_id):
    db = get_db_instance()
    notification_use_cases = NotificationUseCases(db)

    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    # Intentar obtener las notificaciones desde Redis
    cache_key = f"notifications:{user_id}:page:{page}"
    cached_notifications = redis_client.get(cache_key)
    if cached_notifications:
        try:
            notifications = json.loads(cached_notifications)
            return jsonify(notifications), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a obtener desde la base de datos

    # Si no hay caché, obtener desde MongoDB
    notifications = notification_use_cases.list_user_notifications(user_id, page, limit)
    serialized_notifications = [serialize_doc(notification) for notification in notifications]

    # Cachear los resultados en Redis
    redis_client.set(cache_key, json.dumps(serialized_notifications), ex=60*5)  # Expiración en 5 minutos

    return jsonify(serialized_notifications), 200

# Ruta para eliminar una notificación
@notification_controller.route('/api/notifications/<notification_id>/delete', methods=['DELETE'])
@jwt_required()
def delete_notification(notification_id):
    db = get_db_instance()
    notification_use_cases = NotificationUseCases(db)

    # Eliminar la notificación
    result = notification_use_cases.delete_notification(notification_id)
    if result:
        # Eliminar de Redis
        redis_client.delete(f"notification:{notification_id}")

        # Emitir a través de WebSocket que la notificación fue eliminada
        socketio.emit('notification_deleted', {"notification_id": notification_id})

        return jsonify({"message": "Notificación eliminada exitosamente"}), 200

    return jsonify({"error": "Error al eliminar la notificación"}), 400
