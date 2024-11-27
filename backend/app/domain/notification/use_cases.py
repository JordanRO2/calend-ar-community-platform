# relative path: app/domain/notification/use_cases.py

from marshmallow import ValidationError
from .repositories import NotificationRepository
from .entities import NotificationSchema

class NotificationUseCases:
    """Clase que define los casos de uso para la entidad Notification."""

    def __init__(self, db):
        self.notification_repository = NotificationRepository(db)
        self.notification_schema = NotificationSchema()

    def create_notification(self, notification_data):
        """Crea una nueva notificación."""
        try:
            # Validar los datos de la notificación utilizando Marshmallow
            validated_data = self.notification_schema.load(notification_data)
            notification_id = self.notification_repository.create_notification(validated_data)
            return {"message": "Notificación creada exitosamente", "notification_id": notification_id}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def mark_notification_as_read(self, notification_id):
        """Marca una notificación como leída."""
        try:
            marked = self.notification_repository.mark_as_read(notification_id)
            if marked:
                return {"message": "Notificación marcada como leída exitosamente"}
            return {"error": "Error al marcar la notificación como leída"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_notification_details(self, notification_id):
        """Obtiene los detalles de una notificación."""
        try:
            notification = self.notification_repository.get_notification_by_id(notification_id)
            if notification:
                return notification
            return {"error": "Notificación no encontrada"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_user_notifications(self, user_id, page=1, limit=10):
        """Lista las notificaciones de un usuario."""
        try:
            notifications = self.notification_repository.get_notifications_by_user(user_id, page, limit)
            return notifications
        except Exception as ex:
            return {"error": str(ex)}

    def delete_notification(self, notification_id):
        """Elimina una notificación."""
        try:
            deleted = self.notification_repository.delete_notification(notification_id)
            if deleted:
                return {"message": "Notificación eliminada exitosamente"}
            return {"error": "Error al eliminar la notificación"}
        except Exception as ex:
            return {"error": str(ex)}
