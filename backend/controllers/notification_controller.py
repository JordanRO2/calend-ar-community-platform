from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity

# Crear el Blueprint
notification_controller = Blueprint('notification_controller', __name__)

# Ruta para obtener notificaciones por user_id
@notification_controller.route('/users/<user_id>/notifications', methods=['GET'])
@jwt_required()
def get_notifications(user_id):
    try:
        current_user_id = get_jwt_identity()
        if current_user_id != user_id:
            return jsonify({"error": "No tienes permiso para ver las notificaciones de otro usuario"}), 403

        notification_service = current_app.notification_service
        notifications = notification_service.get_notifications_by_user_id(user_id)
        return jsonify([notification.to_dict() for notification in notifications]), 200
    except Exception as e:
        current_app.logger.error(f"Error al obtener notificaciones para el usuario {user_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para marcar una notificación como leída
@notification_controller.route('/notifications/<notification_id>/mark-read', methods=['PUT'])
@jwt_required()
def mark_notification_as_read(notification_id):
    try:
        current_user_id = get_jwt_identity()
        notification_service = current_app.notification_service

        # Verificar que la notificación pertenezca al usuario autenticado
        notification = notification_service.get_notification_by_id(notification_id)
        if not notification or str(notification.user_id) != str(current_user_id):
            return jsonify({"error": "No tienes permiso para marcar esta notificación"}), 403

        notification_service.mark_notification_as_read(notification_id)
        return jsonify({"message": "Notificación marcada como leída"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al marcar notificación como leída {notification_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para eliminar una notificación
@notification_controller.route('/notifications/<notification_id>', methods=['DELETE'])
@jwt_required()
def delete_notification(notification_id):
    try:
        current_user_id = get_jwt_identity()
        notification_service = current_app.notification_service

        # Verificar que la notificación pertenezca al usuario autenticado
        notification = notification_service.get_notification_by_id(notification_id)
        if not notification or str(notification.user_id) != str(current_user_id):
            return jsonify({"error": "No tienes permiso para eliminar esta notificación"}), 403

        notification_service.delete_notification(notification_id)
        return jsonify({"message": "Notificación eliminada exitosamente"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al eliminar notificación {notification_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500
