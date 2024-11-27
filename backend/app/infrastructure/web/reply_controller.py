# relative path: app/infrastructure/web/reply_controller.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.domain.reply.use_cases import ReplyUseCases
from app.infrastructure.db import get_db_instance  # Asume que get_db_instance devuelve una instancia de la base de datos
from app.infrastructure.cache.redis_client import redis_client  # Importar cliente Redis
from app.infrastructure.websockets.socketio import socketio  # Importar instancia de SocketIO
from bson import ObjectId
import json

reply_controller = Blueprint('reply_controller', __name__)

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

# Ruta para crear una respuesta a un comentario
@reply_controller.route('/api/comments/<comment_id>/replies', methods=['POST'])
@jwt_required()
def create_reply(comment_id):
    db = get_db_instance()
    reply_use_cases = ReplyUseCases(db)
    
    reply_data = request.get_json()
    reply_data['user_id'] = get_jwt_identity()  # Añade el ID del usuario autenticado

    # Crear la respuesta
    result = reply_use_cases.create_reply(comment_id, reply_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar el resultado
    serialized_result = serialize_doc(result)

    # Obtener el ID de la respuesta creada
    reply_id = str(result["_id"]) if isinstance(result.get("_id"), ObjectId) else result.get("_id")

    # Emitir notificación a través de WebSocket
    socketio.emit('new_reply', {'comment_id': comment_id, 'reply_id': reply_id})

    # Limpiar la caché relacionada con las respuestas del comentario
    # Para patrones de caché con paginación, usar expresiones regulares o prefijos según la configuración de Redis
    # Aquí se asume que se está usando Redis con patrones específicos de claves
    # Si Redis no soporta patrones en el comando DELETE, considera usar SCAN y DELETE en un loop
    # Por simplicidad, se muestra cómo eliminar claves específicas
    # Aquí eliminamos todas las páginas relacionadas
    # Puedes implementar una lógica más robusta si es necesario
    # Ejemplo:
    # for key in redis_client.scan_iter(f"replies:{comment_id}:page:*"):
    #     redis_client.delete(key)
    
    # Si tu cliente Redis soporta patrones en el comando DELETE (como Redis 6.2+), puedes usar:
    # redis_client.delete_pattern(f"replies:{comment_id}:page:*")
    # Sin embargo, Flask-Redis no tiene un método delete_pattern por defecto
    # Por lo tanto, aquí usamos scan_iter
    for key in redis_client.scan_iter(f"replies:{comment_id}:page:*"):
        redis_client.delete(key)

    return jsonify({"message": "Respuesta creada exitosamente", "reply_id": reply_id}), 201

# Ruta para actualizar una respuesta
@reply_controller.route('/api/replies/<reply_id>/update', methods=['PUT'])
@jwt_required()
def update_reply(reply_id):
    db = get_db_instance()
    reply_use_cases = ReplyUseCases(db)
    
    new_data = request.get_json()

    # Actualizar la respuesta
    result = reply_use_cases.update_reply(reply_id, new_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar los nuevos datos
    serialized_result = serialize_doc(result)

    # Limpiar la caché relacionada con la respuesta actualizada
    redis_client.delete(f"replies:{reply_id}")

    # Emitir notificación a través de WebSocket indicando que la respuesta fue actualizada
    socketio.emit('reply_updated', {"reply_id": reply_id})

    return jsonify({"message": "Respuesta actualizada exitosamente"}), 200

# Ruta para eliminar una respuesta
@reply_controller.route('/api/replies/<reply_id>/delete', methods=['DELETE'])
@jwt_required()
def delete_reply(reply_id):
    db = get_db_instance()
    reply_use_cases = ReplyUseCases(db)
    
    # Eliminar la respuesta
    result = reply_use_cases.delete_reply(reply_id)
    if result:
        # Obtener el ID del evento asociado si es necesario
        event_id = result.get('event_id')  # Asume que `result` contiene `event_id`

        # Limpiar la caché de la respuesta eliminada
        redis_client.delete(f"replies:{reply_id}")

        # Emitir notificación a través de WebSocket sobre la eliminación
        socketio.emit('reply_deleted', {'reply_id': reply_id})

        return jsonify({"message": "Respuesta eliminada exitosamente"}), 200

    return jsonify({"error": "Error al eliminar la respuesta"}), 400

# Ruta para listar las respuestas de un comentario con paginación
@reply_controller.route('/api/comments/<comment_id>/replies', methods=['GET'])
def list_comment_replies(comment_id):
    db = get_db_instance()
    reply_use_cases = ReplyUseCases(db)
    
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    # Intentar obtener las respuestas desde Redis
    cache_key = f"replies:{comment_id}:page:{page}"
    cached_replies = redis_client.get(cache_key)
    if cached_replies:
        try:
            replies = json.loads(cached_replies)
            return jsonify(replies), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a obtener desde la base de datos

    # Si no están en caché, obtenerlas de la base de datos
    replies = reply_use_cases.list_comment_replies(comment_id, page, limit)
    serialized_replies = [serialize_doc(reply) for reply in replies]

    # Cachear las respuestas en Redis
    redis_client.set(cache_key, json.dumps(serialized_replies), ex=60*5)  # Expiración de 5 minutos

    return jsonify(serialized_replies), 200

# Ruta para dar like a una respuesta
@reply_controller.route('/api/replies/<reply_id>/like', methods=['POST'])
@jwt_required()
def like_reply(reply_id):
    db = get_db_instance()
    reply_use_cases = ReplyUseCases(db)
    
    user_id = get_jwt_identity()
    result = reply_use_cases.like_reply(reply_id, user_id)
    if result:
        user_id_str = str(user_id) if isinstance(user_id, ObjectId) else user_id

        # Limpiar la caché relacionada con la respuesta que ha recibido un like
        redis_client.delete(f"replies:{reply_id}")

        # Emitir notificación a través de WebSocket
        socketio.emit('reply_liked', {"reply_id": reply_id, "user_id": user_id_str})

        return jsonify({"message": "Like registrado exitosamente"}), 200

    return jsonify({"error": "Error al registrar el like"}), 400

# Ruta para listar los likes de una respuesta
@reply_controller.route('/api/replies/<reply_id>/likes', methods=['GET'])
def list_reply_likes(reply_id):
    db = get_db_instance()
    reply_use_cases = ReplyUseCases(db)
    
    # Intentar obtener los likes desde Redis
    cache_key = f"likes:{reply_id}"
    cached_likes = redis_client.get(cache_key)
    if cached_likes:
        try:
            likes = json.loads(cached_likes)
            return jsonify(likes), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a obtener desde la base de datos

    # Si no hay caché, obtener los likes desde la base de datos
    likes = reply_use_cases.get_reply_likes(reply_id)
    serialized_likes = [serialize_doc(like) for like in likes]

    # Cachear los likes en Redis
    redis_client.set(cache_key, json.dumps(serialized_likes), ex=60*5)  # Expiración de 5 minutos

    return jsonify(serialized_likes), 200
