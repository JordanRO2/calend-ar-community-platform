from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime

# Crear el Blueprint
event_controller = Blueprint('event_controller', __name__)

# Ruta para obtener un evento por ID
@event_controller.route('/events/<event_id>', methods=['GET'])
@jwt_required()
def get_event(event_id):
    try:
        event_service = current_app.event_service
        event = event_service.get_event_by_id(event_id)
        if event:
            return jsonify(event.to_dict()), 200
        else:
            return jsonify({"error": "Evento no encontrado"}), 404
    except Exception as e:
        current_app.logger.error(f"Error al obtener evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para obtener todos los eventos (con paginación y visibilidad opcional)
@event_controller.route('/events', methods=['GET'])
@jwt_required()
def get_all_events():
    try:
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 10))
        visibility = request.args.get('visibility', None)  # Filtrar eventos por visibilidad si se proporciona
        event_service = current_app.event_service
        
        if visibility:
            events = event_service.get_events_by_visibility(visibility, page, per_page)
        else:
            events = event_service.get_all_events(page, per_page)
        
        return jsonify([event.to_dict() for event in events]), 200
    except Exception as e:
        current_app.logger.error(f"Error al obtener eventos: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para obtener eventos destacados (featured)
@event_controller.route('/events/featured', methods=['GET'])
@jwt_required()
def get_featured_events():
    try:
        page = int(request.args.get('page', 1))
        per_page = int(request.args.get('per_page', 5))
        event_service = current_app.event_service
        events = event_service.get_featured_events(page, per_page)
        return jsonify([event.to_dict() for event in events]), 200
    except Exception as e:
        current_app.logger.error(f"Error al obtener eventos destacados: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para crear un nuevo evento (con opción de añadir todas las recurrencias)
@event_controller.route('/events', methods=['POST'])
@jwt_required()
def create_event():
    try:
        event_data = request.get_json()
        if not event_data:
            return jsonify({"error": "No se proporcionaron datos"}), 400

        add_all_recurrences = event_data.get('add_all_recurrences', False)  # Option to add all recurring instances
        creator_user_id = get_jwt_identity()  # ID del usuario creador
        event_service = current_app.event_service
        new_event = event_service.create_event(event_data, creator_user_id, add_all_recurrences=add_all_recurrences)
        return jsonify(new_event.to_dict()), 201
    except Exception as e:
        current_app.logger.error(f"Error al crear evento: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para actualizar un evento por ID
@event_controller.route('/events/<event_id>', methods=['PUT'])
@jwt_required()
def update_event(event_id):
    try:
        event_data = request.get_json()
        if not event_data:
            return jsonify({"error": "No se proporcionaron datos"}), 400

        user_id = get_jwt_identity()
        event_service = current_app.event_service
        updated_event = event_service.update_event(event_id, event_data, user_id)
        if updated_event:
            return jsonify(updated_event.to_dict()), 200
        else:
            return jsonify({"error": "Evento no encontrado"}), 404
    except Exception as e:
        current_app.logger.error(f"Error al actualizar evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para eliminar un evento por ID
@event_controller.route('/events/<event_id>', methods=['DELETE'])
@jwt_required()
def delete_event(event_id):
    try:
        user_id = get_jwt_identity()
        event_service = current_app.event_service
        event_service.delete_event(event_id, user_id)
        return jsonify({"message": "Evento eliminado exitosamente"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al eliminar evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para unirse a un evento (RSVP)
@event_controller.route('/events/<event_id>/rsvp', methods=['POST'])
@jwt_required()
def rsvp_event(event_id):
    try:
        user_id = get_jwt_identity()
        event_service = current_app.event_service
        event_service.confirm_rsvp(event_id, user_id)
        return jsonify({"message": "Te has registrado en el evento exitosamente"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al registrarse en evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para cancelar RSVP de un evento
@event_controller.route('/events/<event_id>/rsvp', methods=['DELETE'])
@jwt_required()
def cancel_rsvp_event(event_id):
    try:
        user_id = get_jwt_identity()
        event_service = current_app.event_service
        event_service.cancel_rsvp(event_id, user_id)
        return jsonify({"message": "Has cancelado tu registro en el evento"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al cancelar registro en evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para unirse a un evento como asistente (opción de unirse a todas las recurrencias)
@event_controller.route('/events/<event_id>/join', methods=['POST'])
@jwt_required()
def join_event(event_id):
    try:
        user_id = get_jwt_identity()
        join_all_recurrences = request.get_json().get('join_all_recurrences', False)  # Option to join all recurring instances
        event_service = current_app.event_service
        event_service.join_event(event_id, user_id, join_all_recurrences=join_all_recurrences)
        return jsonify({"message": "Te has unido al evento exitosamente"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al unirse al evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para abandonar un evento
@event_controller.route('/events/<event_id>/leave', methods=['DELETE'])
@jwt_required()
def leave_event(event_id):
    try:
        user_id = get_jwt_identity()
        event_service = current_app.event_service
        event_service.leave_event(event_id, user_id)
        return jsonify({"message": "Has abandonado el evento"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al abandonar el evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500
