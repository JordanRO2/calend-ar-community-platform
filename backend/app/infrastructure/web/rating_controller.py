# relative path: app/infrastructure/web/rating_controller.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.domain.rating.use_cases import RatingUseCases
from app.infrastructure.db import get_db_instance  # Asume que get_db_instance devuelve una instancia de la base de datos
from app.infrastructure.cache.redis_client import redis_client  # Importar cliente Redis
from app.infrastructure.websockets.socketio import socketio  # Importar instancia de SocketIO
from bson import ObjectId
import json

rating_controller = Blueprint('rating_controller', __name__)

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

# Ruta para crear una nueva puntuación para un evento
@rating_controller.route('/api/ratings/<event_id>', methods=['POST'])
@jwt_required()
def create_rating(event_id):
    db = get_db_instance()
    rating_use_cases = RatingUseCases(db)

    rating_data = request.get_json()
    rating_data['user_id'] = get_jwt_identity()  # Añade el ID del usuario autenticado

    # Crear la puntuación
    result = rating_use_cases.create_rating(event_id, rating_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar el resultado
    serialized_result = serialize_doc(result)

    # Obtener el ID de la puntuación creada
    rating_id = str(result["_id"]) if isinstance(result.get("_id"), ObjectId) else result.get("_id")

    # Emitir un mensaje en WebSocket sobre la nueva puntuación
    socketio.emit('new_rating', {'event_id': event_id, 'rating_id': rating_id})

    # Limpiar la caché relacionada con las puntuaciones del evento y el promedio
    redis_client.delete(f"ratings:{event_id}:page:*")
    redis_client.delete(f"average_rating:{event_id}")

    return jsonify({"message": "Puntuación creada exitosamente", "rating_id": rating_id}), 201

# Ruta para actualizar una puntuación existente
@rating_controller.route('/api/ratings/<rating_id>/update', methods=['PUT'])
@jwt_required()
def update_rating(rating_id):
    db = get_db_instance()
    rating_use_cases = RatingUseCases(db)

    new_data = request.get_json()

    # Actualizar la puntuación
    result = rating_use_cases.update_rating(rating_id, new_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar los nuevos datos
    serialized_result = serialize_doc(result)

    # Limpiar la caché relacionada con la puntuación y el promedio del evento
    event_id = new_data.get('event_id')
    redis_client.delete(f"ratings:{rating_id}")
    if event_id:
        redis_client.delete(f"average_rating:{event_id}")

    # Emitir un mensaje en WebSocket indicando que la puntuación fue actualizada
    socketio.emit('rating_updated', {"rating_id": rating_id})

    return jsonify({"message": "Puntuación actualizada exitosamente"}), 200

# Ruta para eliminar una puntuación
@rating_controller.route('/api/ratings/<rating_id>/delete', methods=['DELETE'])
@jwt_required()
def delete_rating(rating_id):
    db = get_db_instance()
    rating_use_cases = RatingUseCases(db)

    # Eliminar la puntuación
    result = rating_use_cases.delete_rating(rating_id)
    if result:
        # Obtener el ID del evento asociado (asume que `result` contiene `event_id`)
        event_id = result.get('event_id')
        if event_id:
            # Limpiar la caché relacionada con la puntuación y el promedio del evento
            redis_client.delete(f"ratings:{rating_id}")
            redis_client.delete(f"average_rating:{event_id}")

        # Emitir un mensaje en WebSocket indicando que la puntuación fue eliminada
        socketio.emit('rating_deleted', {"rating_id": rating_id})

        return jsonify({"message": "Puntuación eliminada exitosamente"}), 200

    return jsonify({"error": "Error al eliminar la puntuación"}), 400

# Ruta para listar las puntuaciones de un evento con paginación
@rating_controller.route('/api/ratings/<event_id>', methods=['GET'])
def list_event_ratings(event_id):
    db = get_db_instance()
    rating_use_cases = RatingUseCases(db)

    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    # Intentar obtener las puntuaciones desde Redis
    cache_key = f"ratings:{event_id}:page:{page}"
    cached_ratings = redis_client.get(cache_key)
    if cached_ratings:
        try:
            ratings = json.loads(cached_ratings)
            return jsonify(ratings), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a obtener desde la base de datos

    # Si no hay caché, obtener desde la base de datos
    ratings = rating_use_cases.list_event_ratings(event_id, page, limit)
    serialized_ratings = [serialize_doc(rating) for rating in ratings]

    # Cachear las puntuaciones en Redis
    redis_client.set(cache_key, json.dumps(serialized_ratings), ex=60*5)  # Expiración en 5 minutos

    return jsonify(serialized_ratings), 200

# Ruta para calcular la puntuación promedio de un evento
@rating_controller.route('/api/ratings/<event_id>/average', methods=['GET'])
def calculate_average_rating(event_id):
    db = get_db_instance()
    rating_use_cases = RatingUseCases(db)

    # Intentar obtener el promedio desde Redis
    cache_key = f"average_rating:{event_id}"
    cached_average = redis_client.get(cache_key)
    if cached_average:
        try:
            average = float(cached_average)
            return jsonify({"average_rating": average}), 200
        except (ValueError, TypeError):
            pass  # Si hay un error en la decodificación, proceder a calcular desde la base de datos

    # Si no hay caché, calcular el promedio desde la base de datos
    average_rating = rating_use_cases.calculate_event_average_rating(event_id)
    if average_rating is not None:
        # Cachear el promedio en Redis
        redis_client.set(cache_key, average_rating, ex=60*5)  # Expiración en 5 minutos
        return jsonify({"average_rating": average_rating}), 200

    return jsonify({"error": "Error al calcular la puntuación promedio"}), 400
