from bson import ObjectId
from flask import current_app
from core.domain.notification import Notification, NotificationStatus

class NotificationRepository:
    def __init__(self, db):
        self.notifications = db.notifications

    def get_by_user_id(self, user_id):
        """Obtiene todas las notificaciones de un usuario."""
        try:
            notifications_list = []
            for notification_data in self.notifications.find({'user_id': ObjectId(user_id)}):
                notification_data['id'] = str(notification_data.pop('_id'))
                notification_data['event_id'] = str(notification_data['event_id']) if notification_data.get('event_id') else None  # Convertir ObjectId a string
                notifications_list.append(Notification.from_dict(notification_data))
            return notifications_list
        except Exception as e:
            current_app.logger.error(f"Error al obtener notificaciones: {str(e)}")
            raise Exception("Error al obtener las notificaciones")

    def get_by_id(self, notification_id):
        """Obtiene una notificación por su ID."""
        try:
            notification_data = self.notifications.find_one({'_id': ObjectId(notification_id)})
            if notification_data:
                notification_data['id'] = str(notification_data.pop('_id'))
                notification_data['event_id'] = str(notification_data['event_id']) if notification_data.get('event_id') else None  # Convertir ObjectId a string
                return Notification.from_dict(notification_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener notificación: {str(e)}")
            raise Exception("Error al obtener la notificación")

    def create(self, notification):
        """Crea una nueva notificación."""
        try:
            notification_dict = notification.to_dict()
            notification_dict['_id'] = ObjectId()  # Generar nuevo _id
            if notification_dict.get('event_id'):
                notification_dict['event_id'] = ObjectId(notification_dict['event_id'])  # Convertir 'event_id' a ObjectId
            self.notifications.insert_one(notification_dict)
            current_app.logger.info(f"Notificación creada exitosamente")
        except Exception as e:
            current_app.logger.error(f"Error al crear notificación: {str(e)}")
            raise Exception("Error al crear la notificación")

    def update(self, notification):
        """Actualiza una notificación existente."""
        try:
            notification_dict = notification.to_dict()
            notification_dict['_id'] = ObjectId(notification_dict.pop('id'))  # Convertir 'id' a ObjectId
            if notification_dict.get('event_id'):
                notification_dict['event_id'] = ObjectId(notification_dict['event_id'])  # Convertir 'event_id' a ObjectId
            result = self.notifications.update_one({'_id': notification_dict['_id']}, {'$set': notification_dict})
            if result.matched_count == 0:
                raise ValueError("Notificación no encontrada")
            current_app.logger.info(f"Notificación actualizada exitosamente")
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar notificación: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar notificación: {str(e)}")
            raise Exception("Error al actualizar la notificación")

    def delete(self, notification_id):
        """Elimina una notificación por su ID."""
        try:
            result = self.notifications.delete_one({'_id': ObjectId(notification_id)})
            if result.deleted_count == 0:
                raise ValueError("Notificación no encontrada")
            current_app.logger.info(f"Notificación con ID {notification_id} eliminada exitosamente")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar notificación: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar notificación: {str(e)}")
            raise Exception("Error al eliminar la notificación")

    def mark_as_read(self, notification_id):
        """Marca una notificación como leída."""
        try:
            result = self.notifications.update_one(
                {'_id': ObjectId(notification_id)},
                {'$set': {'status': NotificationStatus.READ}}
            )
            if result.matched_count == 0:
                raise ValueError("Notificación no encontrada para marcar como leída")
            current_app.logger.info(f"Notificación con ID {notification_id} marcada como leída")
        except ValueError as ve:
            current_app.logger.error(f"Error al marcar notificación como leída: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al marcar notificación como leída: {str(e)}")
            raise Exception("Error al marcar la notificación como leída")

    def mark_as_unread(self, notification_id):
        """Marca una notificación como no leída."""
        try:
            result = self.notifications.update_one(
                {'_id': ObjectId(notification_id)},
                {'$set': {'status': NotificationStatus.UNREAD}}
            )
            if result.matched_count == 0:
                raise ValueError("Notificación no encontrada para marcar como no leída")
            current_app.logger.info(f"Notificación con ID {notification_id} marcada como no leída")
        except ValueError as ve:
            current_app.logger.error(f"Error al marcar notificación como no leída: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al marcar notificación como no leída: {str(e)}")
            raise Exception("Error al marcar la notificación como no leída")
