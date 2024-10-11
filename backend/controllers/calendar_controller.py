from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from core.utils.auth_utils import admin_required

# Crear el Blueprint
calendar_controller = Blueprint('calendar_controller', __name__)

# Ruta para obtener un calendario personalizado por ID
@calendar_controller.route('/calendars/<calendar_id>', methods=['GET'])
@jwt_required()
def get_calendar(calendar_id):
    try:
        calendar_service = current_app.calendar_service
        calendar = calendar_service.get_calendar_by_id(calendar_id)
        if calendar:
            return jsonify(calendar.to_dict()), 200
        else:
            return jsonify({"error": "Calendario no encontrado"}), 404
    except ValueError as ve:
        current_app.logger.error(f"Error fetching calendar {calendar_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 404
    except Exception as e:
        current_app.logger.error(f"Error inesperado fetching calendar {calendar_id}: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500

# Ruta para crear un nuevo calendario personalizado
@calendar_controller.route('/calendars', methods=['POST'])
@jwt_required()
def create_calendar():
    try:
        calendar_data = request.get_json()
        if not calendar_data:
            return jsonify({"error": "No se proporcionaron datos"}), 400

        calendar_service = current_app.calendar_service
        new_calendar = calendar_service.create_calendar(calendar_data)
        return jsonify(new_calendar.to_dict()), 201
    except ValueError as ve:
        current_app.logger.error(f"Error al crear calendario: {str(ve)}")
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        current_app.logger.error(f"Error inesperado al crear calendario: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500

# Ruta para actualizar un calendario personalizado
@calendar_controller.route('/calendars/<calendar_id>', methods=['PUT'])
@jwt_required()
def update_calendar(calendar_id):
    try:
        calendar_data = request.get_json()
        if not calendar_data:
            return jsonify({"error": "No se proporcionaron datos para la actualización"}), 400

        calendar_service = current_app.calendar_service
        updated_calendar = calendar_service.update_calendar(calendar_id, calendar_data)
        if updated_calendar:
            return jsonify(updated_calendar.to_dict()), 200
        else:
            return jsonify({"error": "Calendario no encontrado"}), 404
    except ValueError as ve:
        current_app.logger.error(f"Error al actualizar calendario {calendar_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 404
    except Exception as e:
        current_app.logger.error(f"Error inesperado al actualizar calendario {calendar_id}: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500

# Ruta para eliminar un calendario personalizado
@calendar_controller.route('/calendars/<calendar_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_calendar(calendar_id):
    try:
        calendar_service = current_app.calendar_service
        calendar_service.delete_calendar(calendar_id)
        return jsonify({"message": "Calendario eliminado exitosamente"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error al eliminar calendario {calendar_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 404
    except Exception as e:
        current_app.logger.error(f"Error inesperado al eliminar calendario {calendar_id}: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500

# Ruta para agregar un evento a un calendario personalizado
@calendar_controller.route('/calendars/<calendar_id>/events/<event_id>', methods=['POST'])
@jwt_required()
def add_event_to_calendar(calendar_id, event_id):
    try:
        add_all_recurrences = request.get_json().get('add_all_recurrences', False)  # Opción de añadir todas las recurrencias
        calendar_service = current_app.calendar_service
        calendar_service.add_event_to_calendar(calendar_id, event_id, add_all_recurrences=add_all_recurrences)
        return jsonify({"message": "Evento agregado exitosamente"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error al agregar evento {event_id} al calendario {calendar_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 404
    except Exception as e:
        current_app.logger.error(f"Error inesperado al agregar evento {event_id} al calendario {calendar_id}: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500

# Ruta para eliminar un evento de un calendario personalizado
@calendar_controller.route('/calendars/<calendar_id>/events/<event_id>', methods=['DELETE'])
@jwt_required()
def remove_event_from_calendar(calendar_id, event_id):
    try:
        calendar_service = current_app.calendar_service
        calendar_service.remove_event_from_calendar(calendar_id, event_id)
        return jsonify({"message": "Evento eliminado exitosamente"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error al eliminar evento {event_id} del calendario {calendar_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 404
    except Exception as e:
        current_app.logger.error(f"Error inesperado al eliminar evento {event_id} del calendario {calendar_id}: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500
