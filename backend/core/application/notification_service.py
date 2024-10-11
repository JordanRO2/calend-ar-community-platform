from flask import current_app
from core.domain.notification import Notification, NotificationStatus

class NotificationService:
    def __init__(self, notification_repository, user_repository):
        self.notification_repository = notification_repository
        self.user_repository = user_repository

    def get_notifications_by_user_id(self, user_id):
        """Obtiene todas las notificaciones de un usuario."""
        try:
            return self.notification_repository.get_by_user_id(user_id)
        except Exception as e:
            current_app.logger.error(f"Error al obtener notificaciones: {str(e)}")
            raise Exception("Error al obtener las notificaciones")

    def delete_notification(self, notification_id, user_id):
        """Elimina una notificación si pertenece al usuario."""
        try:
            notification = self.notification_repository.get_by_id(notification_id)
            if not notification:
                raise ValueError("La notificación no existe.")
            if str(notification.user_id) != str(user_id):
                raise ValueError("No tienes permisos para eliminar esta notificación.")
            self.notification_repository.delete(notification_id)
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar notificación: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar notificación: {str(e)}")
            raise Exception("Error al eliminar la notificación")

    def mark_notification_as_read(self, notification_id, user_id):
        """Marca una notificación como leída si pertenece al usuario."""
        try:
            notification = self.notification_repository.get_by_id(notification_id)
            if not notification:
                raise ValueError("La notificación no existe.")
            if str(notification.user_id) != str(user_id):
                raise ValueError("No tienes permisos para marcar esta notificación como leída.")

            # Actualizar el estado de la notificación
            notification.mark_as_read()
            self.notification_repository.update(notification)
        except ValueError as ve:
            current_app.logger.error(f"Error al marcar notificación como leída: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al marcar notificación como leída: {str(e)}")
            raise Exception("Error al marcar la notificación como leída")

    def mark_notification_as_unread(self, notification_id, user_id):
        """Marca una notificación como no leída si pertenece al usuario."""
        try:
            notification = self.notification_repository.get_by_id(notification_id)
            if not notification:
                raise ValueError("La notificación no existe.")
            if str(notification.user_id) != str(user_id):
                raise ValueError("No tienes permisos para marcar esta notificación como no leída.")

            notification.mark_as_unread()
            self.notification_repository.update(notification)
        except ValueError as ve:
            current_app.logger.error(f"Error al marcar notificación como no leída: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al marcar notificación como no leída: {str(e)}")
            raise Exception("Error al marcar la notificación como no leída")

    def create_notification(self, notification_data):
        """Crea una nueva notificación y envía en tiempo real mediante WebSocket."""
        try:
            notification = Notification(**notification_data)
            self.notification_repository.create(notification)

            # Emitir notificación en tiempo real al usuario mediante current_app
            current_app.socketio.emit('notification', notification.to_dict(), room=str(notification.user_id))
            
            return notification
        except Exception as e:
            current_app.logger.error(f"Error al crear notificación: {str(e)}")
            raise Exception("Error al crear la notificación")

    def get_unread_notifications_count(self, user_id):
        """Devuelve el número de notificaciones no leídas de un usuario."""
        try:
            notifications = self.get_notifications_by_user_id(user_id)
            unread_count = len([n for n in notifications if n.status == NotificationStatus.UNREAD])
            return unread_count
        except Exception as e:
            current_app.logger.error(f"Error al contar notificaciones no leídas: {str(e)}")
            raise Exception("Error al contar notificaciones no leídas")

    def notify_upcoming_events(self):
        """Envía notificaciones a los usuarios que han confirmado su asistencia a eventos próximos."""
        try:
            event_service = current_app.event_service
            upcoming_events = event_service.get_upcoming_events()

            for event in upcoming_events:
                # Notificar a los usuarios que han confirmado su asistencia
                for attendee_id in event.rsvp_list:
                    notification_data = {
                        'user_id': str(attendee_id),
                        'message': f"El evento '{event.title}' está por comenzar pronto.",
                        'event_id': str(event.id),
                        'status': NotificationStatus.UNREAD
                    }
                    self.create_notification(notification_data)
        except Exception as e:
            current_app.logger.error(f"Error al notificar eventos próximos: {str(e)}")
            raise Exception("Error al notificar eventos próximos")
