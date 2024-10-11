from flask import current_app
from core.domain.comment import Comment
from core.domain.notification import NotificationStatus
from bson import ObjectId

class CommentService:
    def __init__(self, comment_repository, user_repository, notification_service):
        self.comment_repository = comment_repository
        self.user_repository = user_repository
        self.notification_service = notification_service

    def get_comments_by_event_id(self, event_id, page=1, per_page=10):
        """Obtiene los comentarios de un evento específico con paginación."""
        try:
            comments = self.comment_repository.get_by_event_id(event_id, page, per_page)
            return comments
        except Exception as e:
            current_app.logger.error(f"Error al obtener comentarios para el evento {event_id}: {str(e)}")
            raise Exception("Error al obtener los comentarios para el evento")

    def add_comment(self, comment_data):
        """Añade un nuevo comentario a un evento y notifica a los participantes."""
        try:
            # Validar la longitud del texto (no debe exceder los 280 caracteres)
            if len(comment_data.get('text', '')) > 280:
                raise ValueError("El texto del comentario excede los 280 caracteres.")

            # Verificar que el evento exista antes de crear un comentario
            event = current_app.event_service.get_event_by_id(comment_data['event_id'])
            if not event:
                raise ValueError(f"El evento {comment_data['event_id']} no existe.")

            # Verificar que el usuario exista antes de permitir que comente
            user = self.user_repository.get_by_id(comment_data['user_id'])
            if not user:
                raise ValueError(f"El usuario {comment_data['user_id']} no existe.")

            comment = Comment(**comment_data)
            self.comment_repository.create(comment)

            # Crear notificación para los asistentes del evento
            for attendee_id in event.attendees:
                notification_data = {
                    'user_id': str(attendee_id),
                    'message': f"Nuevo comentario en el evento '{event.title}'",
                    'event_id': str(event.id),
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

            # Emitir en tiempo real la creación del comentario
            current_app.socketio.emit('new_comment', comment.to_dict(), room=str(comment_data['event_id']))

            return comment
        except ValueError as ve:
            current_app.logger.error(f"Error al agregar comentario: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al agregar comentario: {str(e)}")
            raise Exception("Error al agregar el comentario")

    def delete_comment(self, comment_id, user_id):
        """Elimina un comentario, asegurando que el usuario tenga permisos y notifica la eliminación."""
        try:
            # Obtener el comentario para validar su existencia y propiedad
            comment = self.comment_repository.get_by_id(comment_id)
            if not comment:
                raise ValueError(f"El comentario {comment_id} no fue encontrado.")

            # Solo el autor del comentario o un administrador puede eliminar el comentario
            if str(comment.user_id) != str(user_id):
                raise ValueError("No tienes permiso para eliminar este comentario.")

            self.comment_repository.delete(comment_id)

            # Crear notificación para la eliminación del comentario
            notification_data = {
                'user_id': str(comment.user_id),
                'message': f"Tu comentario en el evento '{comment.event_id}' fue eliminado.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir en tiempo real la eliminación del comentario
            current_app.socketio.emit('comment_deleted', {'comment_id': str(comment_id)}, room=str(comment.event_id))
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar comentario: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar comentario: {str(e)}")
            raise Exception("Error al eliminar el comentario")

    def update_comment(self, comment_id, user_id, new_text):
        """Actualiza el texto de un comentario si el usuario es el autor y notifica a los asistentes."""
        try:
            # Obtener el comentario
            comment = self.comment_repository.get_by_id(comment_id)
            if not comment:
                raise ValueError(f"El comentario {comment_id} no fue encontrado.")

            # Solo el autor del comentario puede actualizar el comentario
            if str(comment.user_id) != str(user_id):
                raise ValueError("No tienes permiso para actualizar este comentario.")

            # Validar la longitud del nuevo texto
            if len(new_text) > 280:
                raise ValueError("El texto del comentario excede los 280 caracteres.")

            # Actualizar el texto del comentario y guardar los cambios
            comment.text.value = new_text
            self.comment_repository.update(comment)

            # Notificar la actualización del comentario
            notification_data = {
                'user_id': str(comment.user_id),
                'message': f"Tu comentario en el evento '{comment.event_id}' ha sido actualizado.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir en tiempo real la actualización del comentario
            current_app.socketio.emit('comment_updated', comment.to_dict(), room=str(comment.event_id))

            return comment
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar comentario: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar comentario: {str(e)}")
            raise Exception("Error al actualizar el comentario")

    def add_like_to_comment(self, comment_id, user_id):
        """Añade un 'like' a un comentario y notifica al autor."""
        try:
            comment = self.comment_repository.get_by_id(comment_id)
            if not comment:
                raise ValueError("Comentario no encontrado")

            comment.add_like(user_id)
            self.comment_repository.update(comment)

            # Crear notificación para el autor del comentario
            notification_data = {
                'user_id': str(comment.user_id),
                'message': f"Tu comentario ha recibido un 'like'.",
                'comment_id': str(comment.id),
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir en tiempo real la actualización de likes
            current_app.socketio.emit('comment_liked', comment.to_dict(), room=str(comment.event_id))
        except ValueError as ve:
            current_app.logger.error(f"Error al dar 'like' al comentario: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al dar 'like' al comentario: {str(e)}")
            raise Exception("Error al dar 'like' al comentario")

    def remove_like_from_comment(self, comment_id, user_id):
        """Elimina un 'like' de un comentario y notifica al autor."""
        try:
            comment = self.comment_repository.get_by_id(comment_id)
            if not comment:
                raise ValueError("Comentario no encontrado")

            comment.remove_like(user_id)
            self.comment_repository.update(comment)

            # Crear notificación para el autor del comentario
            notification_data = {
                'user_id': str(comment.user_id),
                'message': f"Un 'like' fue removido de tu comentario.",
                'comment_id': str(comment.id),
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir en tiempo real la actualización de likes
            current_app.socketio.emit('comment_unliked', comment.to_dict(), room=str(comment.event_id))
        except ValueError as ve:
            current_app.logger.error(f"Error al remover 'like' del comentario: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al remover 'like' del comentario: {str(e)}")
            raise Exception("Error al remover 'like' del comentario")

    def report_comment(self, comment_id, user_id):
        """Permite a un usuario reportar un comentario y notifica a los moderadores."""
        try:
            comment = self.comment_repository.get_by_id(comment_id)
            if not comment:
                raise ValueError("Comentario no encontrado")

            comment.add_report(user_id)
            self.comment_repository.update(comment)

            # Notificar a los moderadores sobre el reporte
            community = current_app.community_service.get_community_by_id(comment.community_id)
            for moderator_id in community.moderators:
                notification_data = {
                    'user_id': str(moderator_id),
                    'message': f"El comentario en el evento '{comment.event_id}' ha sido reportado.",
                    'comment_id': str(comment.id),
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

            # Emitir en tiempo real el reporte del comentario
            current_app.socketio.emit('comment_reported', comment.to_dict(), room=str(comment.event_id))
        except ValueError as ve:
            current_app.logger.error(f"Error al reportar comentario: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al reportar comentario: {str(e)}")
            raise Exception("Error al reportar comentario")

    def clear_reports(self, comment_id):
        """Limpia los reportes de un comentario después de la revisión."""
        try:
            comment = self.comment_repository.get_by_id(comment_id)
            if not comment:
                raise ValueError("Comentario no encontrado")

            comment.clear_reports()
            self.comment_repository.update(comment)

            # Emitir en tiempo real la limpieza de reportes
            current_app.socketio.emit('reports_cleared', comment.to_dict(), room=str(comment.event_id))
        except ValueError as ve:
            current_app.logger.error(f"Error al limpiar reportes del comentario: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al limpiar reportes del comentario: {str(e)}")
            raise Exception("Error al limpiar reportes del comentario")
