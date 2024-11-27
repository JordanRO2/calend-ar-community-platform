# relative path: app/infrastructure/web/calendar_controller.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from app.domain.calendar.use_cases import CalendarUseCases
from app.infrastructure.db import get_db_instance  # Asume que get_db_instance devuelve una instancia de la base de datos
from app.infrastructure.cache.redis_client import redis_client  # Importar la instancia global de Redis
from app.infrastructure.websockets.socketio import socketio  # Importar la instancia global de SocketIO
from bson import ObjectId
import json

calendar_controller = Blueprint('calendar_controller', __name__)

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

# Ruta para crear un nuevo calendario
@calendar_controller.route('/api/calendars/create', methods=['POST'])
@jwt_required()
def create_calendar():
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    calendar_data = request.get_json()
    
    # Crear el calendario
    result = calendar_use_cases.create_calendar(calendar_data)
    if "error" in result:
        return jsonify(result), 400
    
    # Obtener el ID del calendario creado
    calendar_id = str(result) if isinstance(result, ObjectId) else result
    
    # Notificar a través de WebSocket usando la instancia global de SocketIO
    socketio.emit('calendar_created', {"calendar_id": calendar_id})
    
    # Serializar los datos antes de almacenarlos en Redis
    serialized_data = serialize_doc(calendar_data)
    redis_client.set(f"calendar:{calendar_id}", json.dumps(serialized_data))
    
    return jsonify({"message": "Calendario creado exitosamente", "calendar_id": calendar_id}), 201

# Ruta para obtener los detalles de un calendario
@calendar_controller.route('/api/calendars/<calendar_id>', methods=['GET'])
def get_calendar_details(calendar_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    
    # Buscar en Redis primero
    cached_calendar = redis_client.get(f"calendar:{calendar_id}")
    
    if cached_calendar:
        # Convertir la cadena JSON almacenada en Redis a un diccionario
        try:
            calendar = json.loads(cached_calendar)
            return jsonify(calendar), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a buscar en la base de datos
    
    # Si no está en Redis, buscar en la base de datos
    calendar = calendar_use_cases.get_calendar_details(calendar_id)
    if not calendar:
        return jsonify({"error": "Calendario no encontrado"}), 404
    
    # Serializar el documento
    serialized_calendar = serialize_doc(calendar)
    
    # Almacenar en Redis para la próxima vez
    redis_client.set(f"calendar:{calendar_id}", json.dumps(serialized_calendar))
    
    return jsonify(serialized_calendar), 200

# Ruta para actualizar los detalles de un calendario existente
@calendar_controller.route('/api/calendars/update/<calendar_id>', methods=['PUT'])
@jwt_required()
def update_calendar(calendar_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    new_data = request.get_json()
    
    result = calendar_use_cases.update_calendar(calendar_id, new_data)
    if "error" in result:
        return jsonify(result), 400
    
    # Serializar los nuevos datos
    serialized_data = serialize_doc(new_data)
    
    # Actualizar en Redis después de actualizar en la base de datos
    redis_client.set(f"calendar:{calendar_id}", json.dumps(serialized_data))
    
    # Notificar a través de WebSocket que se actualizó un calendario
    socketio.emit('calendar_updated', {"calendar_id": calendar_id})
    
    return jsonify({"message": "Calendario actualizado exitosamente"}), 200

# Ruta para eliminar un calendario
@calendar_controller.route('/api/calendars/delete/<calendar_id>', methods=['DELETE'])
@jwt_required()
def delete_calendar(calendar_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    
    result = calendar_use_cases.delete_calendar(calendar_id)
    if result:
        # Eliminar del cache Redis
        redis_client.delete(f"calendar:{calendar_id}")
        
        # Notificar a través de WebSocket que se eliminó un calendario
        socketio.emit('calendar_deleted', {"calendar_id": calendar_id})
        
        return jsonify({"message": "Calendario eliminado exitosamente"}), 200
    
    return jsonify({"error": "Error al eliminar el calendario"}), 400

# Ruta para añadir un evento a un calendario
@calendar_controller.route('/api/calendars/<calendar_id>/add-event', methods=['POST'])
@jwt_required()
def add_event_to_calendar(calendar_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    data = request.get_json()
    event_id = data.get('event_id')
    
    result = calendar_use_cases.add_event_to_calendar(calendar_id, event_id)
    if result:
        # Convertir ObjectId a string si es necesario
        event_id_str = str(event_id) if isinstance(event_id, ObjectId) else event_id
        
        # Notificar a través de WebSocket que se añadió un evento
        socketio.emit('event_added_to_calendar', {"calendar_id": calendar_id, "event_id": event_id_str})
        
        return jsonify({"message": "Evento añadido exitosamente al calendario"}), 200
    
    return jsonify({"error": "Error al añadir el evento al calendario"}), 400

# Ruta para eliminar un evento de un calendario
@calendar_controller.route('/api/calendars/<calendar_id>/remove-event/<event_id>', methods=['DELETE'])
@jwt_required()
def remove_event_from_calendar(calendar_id, event_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    
    result = calendar_use_cases.remove_event_from_calendar(calendar_id, event_id)
    if result:
        event_id_str = str(event_id) if isinstance(event_id, ObjectId) else event_id
        
        # Notificar a través de WebSocket que se eliminó un evento
        socketio.emit('event_removed_from_calendar', {"calendar_id": calendar_id, "event_id": event_id_str})
        
        return jsonify({"message": "Evento eliminado exitosamente del calendario"}), 200
    
    return jsonify({"error": "Error al eliminar el evento del calendario"}), 400

# Ruta para listar los suscriptores de un calendario con paginación
@calendar_controller.route('/api/calendars/<calendar_id>/subscribers', methods=['GET'])
@jwt_required()
def list_calendar_subscribers(calendar_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)
    
    result = calendar_use_cases.list_calendar_subscribers(calendar_id, page, limit)
    
    # Serializar los documentos antes de enviarlos
    serialized_result = serialize_doc(result)
    
    return jsonify(serialized_result), 200

# Ruta para listar los calendarios públicos con paginación
@calendar_controller.route('/api/calendars/public', methods=['GET'])
def list_public_calendars():
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)
    
    result = calendar_use_cases.list_public_calendars(page, limit)
    
    # Serializar los documentos antes de enviarlos
    serialized_result = serialize_doc(result)
    
    return jsonify(serialized_result), 200

# Ruta para generar una URL pública para compartir un calendario
@calendar_controller.route('/api/calendars/<calendar_id>/share', methods=['POST'])
@jwt_required()
def share_calendar(calendar_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    
    result = calendar_use_cases.share_calendar(calendar_id)
    if result:
        shared_url = result  # Asume que `result` es la URL generada
        
        # Notificar a través de WebSocket que se compartió un calendario
        socketio.emit('calendar_shared', {"calendar_id": calendar_id, "shared_url": shared_url})
        
        return jsonify({"message": "URL pública generada exitosamente", "shared_url": shared_url}), 200
    
    return jsonify({"error": "Error al generar la URL pública"}), 400

# Ruta para configurar recordatorios de eventos en un calendario
@calendar_controller.route('/api/calendars/<calendar_id>/set-reminder', methods=['POST'])
@jwt_required()
def set_event_reminder(calendar_id):
    db = get_db_instance()
    calendar_use_cases = CalendarUseCases(db)
    data = request.get_json()
    event_id = data.get('event_id')
    reminder_data = data.get('reminder_data')
    
    result = calendar_use_cases.set_event_reminder(calendar_id, event_id, reminder_data)
    if result:
        event_id_str = str(event_id) if isinstance(event_id, ObjectId) else event_id
        
        # Notificar a través de WebSocket que se configuró un recordatorio
        socketio.emit('reminder_set', {"calendar_id": calendar_id, "event_id": event_id_str})
        
        return jsonify({"message": "Recordatorio configurado exitosamente"}), 200
    
    return jsonify({"error": "Error al configurar el recordatorio"}), 400
