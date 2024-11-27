# relative path: app/infrastructure/web/comment_controller.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.domain.comment.use_cases import CommentUseCases
from app.infrastructure.db import get_db_instance
from app.infrastructure.cache.redis_client import redis_client  # Asume que tienes un cliente Redis configurado
from app.infrastructure.websockets.socketio import socketio  # Importar instancia de SocketIO
from bson import ObjectId
import json

comment_controller = Blueprint('comment_controller', __name__)

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

# Ruta para crear un comentario en un evento
@comment_controller.route('/api/comments/<event_id>', methods=['POST'])
@jwt_required()
def create_comment(event_id):
    db = get_db_instance()
    comment_use_cases = CommentUseCases(db)
    comment_data = request.get_json()
    comment_data['user_id'] = get_jwt_identity()  # Añade el ID del usuario autenticado

    # Crear el comentario
    result = comment_use_cases.create_comment(event_id, comment_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar el resultado
    serialized_result = serialize_doc(result)

    # Notificar a los clientes en tiempo real vía WebSocket
    # Asegurarse de que 'comment' está serializado
    socketio.emit('new_comment', {'event_id': event_id, 'comment': serialized_result})

    # Limpiar la caché de comentarios para este evento, ya que los datos han cambiado
    redis_client.delete(f"comments:{event_id}:page:*")

    return jsonify({"message": "Comentario creado exitosamente", "comment_id": str(result["_id"])}), 201

# Ruta para actualizar un comentario
@comment_controller.route('/api/comments/<comment_id>/update', methods=['PUT'])
@jwt_required()
def update_comment(comment_id):
    db = get_db_instance()
    comment_use_cases = CommentUseCases(db)
    new_data = request.get_json()

    # Actualizar el comentario
    result = comment_use_cases.update_comment(comment_id, new_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar los nuevos datos
    serialized_result = serialize_doc(result)

    # Limpiar la caché de comentarios relacionados al comentario actualizado
    redis_client.delete(f"comments:{comment_id}")

    return jsonify({"message": "Comentario actualizado exitosamente"}), 200

# Ruta para eliminar un comentario
@comment_controller.route('/api/comments/<comment_id>/delete', methods=['DELETE'])
@jwt_required()
def delete_comment(comment_id):
    db = get_db_instance()
    comment_use_cases = CommentUseCases(db)

    # Eliminar el comentario
    result = comment_use_cases.delete_comment(comment_id)
    if result:
        # Limpiar la caché de comentarios relacionados al comentario eliminado
        redis_client.delete(f"comments:{comment_id}")
        
        # Emitir notificación de eliminación a través de WebSocket
        socketio.emit('comment_deleted', {"comment_id": comment_id})
        
        return jsonify({"message": "Comentario eliminado exitosamente"}), 200

    return jsonify({"error": "Error al eliminar el comentario"}), 400

# Ruta para listar los comentarios de un evento con paginación
@comment_controller.route('/api/comments/<event_id>', methods=['GET'])
def list_event_comments(event_id):
    db = get_db_instance()
    comment_use_cases = CommentUseCases(db)
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    # Intentar obtener los comentarios desde Redis
    cache_key = f"comments:{event_id}:page:{page}"
    cached_comments = redis_client.get(cache_key)

    if cached_comments:
        try:
            comments = json.loads(cached_comments)
            return jsonify(comments), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a buscar en la base de datos

    # Si no hay caché, obtener los comentarios desde MongoDB
    comments = comment_use_cases.list_event_comments(event_id, page, limit)
    serialized_comments = [serialize_doc(comment) for comment in comments]

    # Almacenar los comentarios en la caché de Redis
    redis_client.set(cache_key, json.dumps(serialized_comments), ex=60*5)  # Expiración en 5 minutos

    return jsonify(serialized_comments), 200

# Ruta para dar like a un comentario
@comment_controller.route('/api/comments/<comment_id>/like', methods=['POST'])
@jwt_required()
def like_comment(comment_id):
    db = get_db_instance()
    comment_use_cases = CommentUseCases(db)
    user_id = get_jwt_identity()

    # Registrar el like
    result = comment_use_cases.like_comment(comment_id, user_id)

    if result:
        # Limpiar la caché de comentarios relacionados al comentario que ha recibido un like
        redis_client.delete(f"comments:{comment_id}")

        # Emitir evento de like a través de WebSocket
        socketio.emit('comment_liked', {"comment_id": comment_id, "user_id": user_id})

        return jsonify({"message": "Like registrado exitosamente"}), 200

    return jsonify({"error": "Error al registrar el like"}), 400

# Ruta para listar los likes de un comentario
@comment_controller.route('/api/comments/<comment_id>/likes', methods=['GET'])
def list_comment_likes(comment_id):
    db = get_db_instance()
    comment_use_cases = CommentUseCases(db)

    # Obtener los likes
    likes = comment_use_cases.get_comment_likes(comment_id)
    serialized_likes = [serialize_doc(like) for like in likes]

    return jsonify(serialized_likes), 200

# Ruta para reportar un comentario inapropiado
@comment_controller.route('/api/comments/<comment_id>/report', methods=['POST'])
@jwt_required()
def report_comment(comment_id):
    db = get_db_instance()
    comment_use_cases = CommentUseCases(db)
    report_data = request.get_json()

    # Reportar el comentario
    result = comment_use_cases.report_comment(comment_id, report_data)

    if result:
        # Limpiar la caché de comentarios relacionados al comentario reportado
        redis_client.delete(f"comments:{comment_id}")

        # Emitir evento de reporte a través de WebSocket
        socketio.emit('comment_reported', {"comment_id": comment_id, "report_data": serialize_doc(report_data)})

        return jsonify({"message": "Comentario reportado exitosamente"}), 200

    return jsonify({"error": "Error al reportar el comentario"}), 400
