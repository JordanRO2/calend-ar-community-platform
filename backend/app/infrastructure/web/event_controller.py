# relative path: app/infrastructure/web/event_controller.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.domain.event.use_cases import EventUseCases
from app.infrastructure.db import get_db_instance  # Asume que get_db_instance devuelve una instancia de la base de datos
from app.infrastructure.cache.redis_client import redis_client  # Importar cliente Redis
from app.infrastructure.websockets.socketio import socketio  # Importar instancia de SocketIO
from bson import ObjectId
import json

event_controller = Blueprint('event_controller', __name__)

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

# Ruta para crear un nuevo evento
@event_controller.route('/api/events/create', methods=['POST'])
@jwt_required()
def create_event():
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    event_data = request.get_json()

    # Crear el evento
    result = event_use_cases.create_event(event_data)
    if "error" in result:
        return jsonify(result), 400

    # Obtener el ID del evento creado
    event_id = str(result) if isinstance(result, ObjectId) else result

    # Notificar a través de WebSocket usando la instancia global de SocketIO
    socketio.emit('event_created', {"event_id": event_id})

    # Serializar los datos antes de almacenarlos en Redis
    serialized_data = serialize_doc(event_data)
    redis_client.set(f"event:{event_id}", json.dumps(serialized_data))

    return jsonify({"message": "Evento creado exitosamente", "event_id": event_id}), 201

# Ruta para obtener los detalles de un evento
@event_controller.route('/api/events/<event_id>', methods=['GET'])
def get_event_details(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)

    # Buscar el evento en Redis primero
    cached_event = redis_client.get(f"event:{event_id}")
    if cached_event:
        try:
            event = json.loads(cached_event)
            return jsonify(event), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a buscar en la base de datos

    # Si no está en Redis, buscar en la base de datos
    event = event_use_cases.get_event_details(event_id)
    if not event:
        return jsonify({"error": "Evento no encontrado"}), 404

    # Serializar el documento
    serialized_event = serialize_doc(event)

    # Almacenar en Redis para la próxima vez
    redis_client.set(f"event:{event_id}", json.dumps(serialized_event))

    return jsonify(serialized_event), 200

# Ruta para actualizar los detalles de un evento existente
@event_controller.route('/api/events/update/<event_id>', methods=['PUT'])
@jwt_required()
def update_event(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    new_data = request.get_json()

    result = event_use_cases.update_event(event_id, new_data)
    if "error" in result:
        return jsonify(result), 400

    # Serializar los nuevos datos
    serialized_data = serialize_doc(result)

    # Actualizar en Redis después de actualizar en la base de datos
    redis_client.set(f"event:{event_id}", json.dumps(serialized_data))

    # Notificar a través de WebSocket que se actualizó un evento
    socketio.emit('event_updated', {"event_id": event_id})

    return jsonify({"message": "Evento actualizado exitosamente"}), 200

# Ruta para eliminar un evento
@event_controller.route('/api/events/delete/<event_id>', methods=['DELETE'])
@jwt_required()
def delete_event(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)

    result = event_use_cases.delete_event(event_id)
    if result:
        # Eliminar del cache de Redis
        redis_client.delete(f"event:{event_id}")

        # Notificar a través de WebSocket que se eliminó un evento
        socketio.emit('event_deleted', {"event_id": event_id})

        return jsonify({"message": "Evento eliminado exitosamente"}), 200

    return jsonify({"error": "Error al eliminar el evento"}), 400

# Ruta para añadir un asistente a un evento
@event_controller.route('/api/events/<event_id>/attend', methods=['POST'])
@jwt_required()
def attend_event(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    user_id = get_jwt_identity()

    result = event_use_cases.add_attendee_to_event(event_id, user_id)
    if result:
        user_id_str = str(user_id) if isinstance(user_id, ObjectId) else user_id

        # Emitir notificación por WebSocket
        socketio.emit('attendee_added', {"event_id": event_id, "user_id": user_id_str})

        # Limpiar la caché de asistentes para este evento
        redis_client.delete(f"attendees:{event_id}:page:*")

        return jsonify({"message": "Asistencia registrada exitosamente"}), 200

    return jsonify({"error": "Error al registrar la asistencia"}), 400

# Ruta para eliminar un asistente de un evento
@event_controller.route('/api/events/<event_id>/attend', methods=['DELETE'])
@jwt_required()
def remove_attendee(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    user_id = get_jwt_identity()

    result = event_use_cases.remove_attendee_from_event(event_id, user_id)
    if result:
        user_id_str = str(user_id) if isinstance(user_id, ObjectId) else user_id

        # Emitir notificación por WebSocket
        socketio.emit('attendee_removed', {"event_id": event_id, "user_id": user_id_str})

        # Limpiar la caché de asistentes para este evento
        redis_client.delete(f"attendees:{event_id}:page:*")

        return jsonify({"message": "Asistencia eliminada exitosamente"}), 200

    return jsonify({"error": "Error al eliminar la asistencia"}), 400

# Ruta para listar los asistentes de un evento con paginación
@event_controller.route('/api/events/<event_id>/attendees', methods=['GET'])
@jwt_required()
def list_event_attendees(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    try:
        result = event_use_cases.list_event_attendees(event_id, page, limit)
        # Serializar los documentos antes de enviarlos
        serialized_result = [serialize_doc(attendee) for attendee in result]
        return jsonify(serialized_result if serialized_result else []), 200
    except Exception as e:
        print(f"Error en la ruta /api/events/<event_id>/attendees: {str(e)}")
        return jsonify({"error": f"Error interno del servidor: {str(e)}"}), 500

# Ruta para marcar un evento como destacado
@event_controller.route('/api/events/<event_id>/feature', methods=['POST'])
@jwt_required()
def mark_event_as_featured(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)

    result = event_use_cases.mark_event_as_featured(event_id)
    if result:
        # Emitir notificación por WebSocket
        socketio.emit('event_featured', {"event_id": event_id})

        # Actualizar en Redis el estado de destacado
        redis_client.set(f"event:{event_id}:featured", True)

        return jsonify({"message": "Evento marcado como destacado"}), 200

    return jsonify({"error": "Error al marcar el evento como destacado"}), 400

# Ruta para listar eventos destacados con paginación
@event_controller.route('/api/events/featured', methods=['GET'])
def list_featured_events():
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    try:
        # Obtener eventos destacados
        result = event_use_cases.list_featured_events(page, limit)
        # Serializar los documentos antes de enviarlos
        serialized_result = [serialize_doc(event) for event in result]

        return jsonify(serialized_result if serialized_result else []), 200
    except Exception as e:
        print(f"Error en la ruta /api/events/featured: {str(e)}")
        return jsonify({"error": f"Error interno del servidor: {str(e)}"}), 500

# Ruta para filtrar eventos según criterios
@event_controller.route('/api/events/filter', methods=['GET'])
def filter_events():
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    filters = request.args.to_dict()
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    try:
        result = event_use_cases.filter_events(filters, page, limit)
        # Serializar los documentos antes de enviarlos
        serialized_result = [serialize_doc(event) for event in result]
        return jsonify(serialized_result if serialized_result else []), 200
    except Exception as e:
        print(f"Error en la ruta /api/events/filter: {str(e)}")
        return jsonify({"error": f"Error interno del servidor: {str(e)}"}), 500

# Ruta para gestionar la recurrencia de un evento
@event_controller.route('/api/events/<event_id>/recurrence', methods=['POST'])
@jwt_required()
def manage_event_recurrence(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)
    recurrence_data = request.get_json()

    result = event_use_cases.manage_recurrence(event_id, recurrence_data)
    if result:
        # Emitir notificación por WebSocket
        socketio.emit('event_recurrence_updated', {"event_id": event_id})

        # Actualizar la recurrencia en Redis si aplica
        redis_client.set(f"event:{event_id}:recurrence", json.dumps(serialize_doc(recurrence_data)))

        return jsonify({"message": "Recurrencia del evento actualizada exitosamente"}), 200

    return jsonify({"error": "Error al actualizar la recurrencia"}), 400

# Ruta para cancelar un evento
@event_controller.route('/api/events/<event_id>/cancel', methods=['POST'])
@jwt_required()
def cancel_event(event_id):
    db = get_db_instance()
    event_use_cases = EventUseCases(db)

    result = event_use_cases.cancel_event(event_id)
    if result:
        # Emitir notificación por WebSocket
        socketio.emit('event_cancelled', {"event_id": event_id})

        # Actualizar el estado de cancelado en Redis
        redis_client.set(f"event:{event_id}:cancelled", True)

        return jsonify({"message": "Evento cancelado exitosamente"}), 200

    return jsonify({"error": "Error al cancelar el evento"}), 400
