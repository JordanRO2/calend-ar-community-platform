from datetime import datetime, timedelta
from bson import ObjectId
from flask import current_app
from core.domain.notification import NotificationStatus
from core.domain.event import Event

class EventService:
    def __init__(self, event_repository, user_repository, notification_service):
        self.event_repository = event_repository
        self.user_repository = user_repository
        self.notification_service = notification_service  # Conectar con el servicio de notificaciones

    def get_event_by_id(self, event_id):
        """Obtiene un evento por su ID."""
        try:
            return self.event_repository.get_by_id(event_id)
        except Exception as e:
            current_app.logger.error(f"Error al obtener evento: {str(e)}")
            raise Exception("Error al obtener el evento")

    def get_all_events(self, page=1, per_page=10, visibility=None):
        """Obtiene todos los eventos con paginación y filtrado opcional por visibilidad."""
        try:
            return self.event_repository.get_all(page=page, per_page=per_page, visibility=visibility)
        except Exception as e:
            current_app.logger.error(f"Error al obtener eventos: {str(e)}")
            raise Exception("Error al obtener los eventos")

    def get_featured_events(self, page=1, per_page=5):
        """Obtiene eventos destacados."""
        try:
            return self.event_repository.get_featured(page=page, per_page=per_page)
        except Exception as e:
            current_app.logger.error(f"Error al obtener eventos destacados: {str(e)}")
            raise Exception("Error al obtener eventos destacados")

    def create_event(self, event_data, creator_user_id, add_all_recurrences=False):
        try:
            community = current_app.community_service.get_community_by_id(event_data["community_id"])
            if not community or str(creator_user_id) not in [str(community.community_admin_id)] + community.moderators:
                raise ValueError("No tienes permiso para crear eventos en esta comunidad.")
            
            event = Event(**event_data)
            self.event_repository.create(event)

            # Notificar a los miembros de la comunidad
            for member_id in community.members:
                notification_data = {
                    'user_id': str(member_id),
                    'message': f"Nuevo evento '{event.title}' ha sido creado en la comunidad '{community.name}'.",
                    'event_id': str(event.id),
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

                # Emitir notificación a través de WebSocket
                current_app.socketio.emit('notification', notification_data, room=str(member_id))

            # Emitir evento de WebSocket a los miembros de la comunidad
            for member_id in community.members:
                current_app.socketio.emit('event_created', event.to_dict(), room=str(member_id))

            # Añadir recurrencias si es necesario
            if add_all_recurrences and event.is_recurring():
                recurrences = event.get_recurring_event_instances(datetime.now() + timedelta(days=365))
                for recurrence in recurrences:
                    recurrence_event_data = event_data.copy()
                    recurrence_event_data['date'] = recurrence
                    self.event_repository.create(Event(**recurrence_event_data))

            return event
        except ValueError as ve:
            current_app.logger.error(f"Error al crear evento: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al crear evento: {str(e)}")
            raise Exception("Error al crear el evento")

    def update_event(self, event_id, event_data, user_id):
        try:
            event = self.get_event_by_id(event_id)
            if not event:
                raise ValueError("Evento no encontrado")

            community = current_app.community_service.get_community_by_id(event.community_id)
            if str(user_id) not in [str(community.community_admin_id)] + community.moderators:
                raise ValueError("No tienes permiso para actualizar eventos en esta comunidad.")

            event.update(event_data)
            self.event_repository.update(event)

            # Notificar a los miembros de la comunidad sobre la actualización del evento
            for member_id in community.members:
                notification_data = {
                    'user_id': str(member_id),
                    'message': f"El evento '{event.title}' ha sido actualizado en la comunidad '{community.name}'.",
                    'event_id': str(event.id),
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

                # Emitir notificación y evento actualizado a través de WebSocket
                current_app.socketio.emit('notification', notification_data, room=str(member_id))
                current_app.socketio.emit('event_updated', event.to_dict(), room=str(member_id))

            return event
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar evento: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar evento: {str(e)}")
            raise Exception("Error al actualizar el evento")

    def delete_event(self, event_id, user_id):
        """Elimina un evento."""
        try:
            event = self.get_event_by_id(event_id)
            if not event:
                raise ValueError("Evento no encontrado")

            community = current_app.community_service.get_community_by_id(event.community_id)
            if str(user_id) != str(community.community_admin_id):
                raise ValueError("Solo el administrador de la comunidad puede eliminar eventos.")

            self.event_repository.delete(event_id)

            # Notificar a los miembros de la comunidad sobre la eliminación del evento
            for member_id in community.members:
                notification_data = {
                    'user_id': str(member_id),
                    'message': f"El evento '{event.title}' ha sido eliminado en la comunidad '{community.name}'.",
                    'event_id': str(event.id),
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

                current_app.logger.info(f"Evento {event_id} eliminado correctamente.")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar evento: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar evento: {str(e)}")
            raise Exception("Error al eliminar el evento")

    def join_event(self, event_id, user_id, join_all_recurrences=False):
        """Permite que un usuario se una a un evento, opcionalmente a todas las recurrencias."""
        try:
            event = self.get_event_by_id(event_id)
            if not event:
                raise ValueError("Evento no encontrado")

            if ObjectId(user_id) in event.attendees:
                raise ValueError("El usuario ya está inscrito en este evento.")

            event.attendees.append(ObjectId(user_id))
            self.event_repository.update(event)

            # Notificar al usuario de su participación en el evento
            notification_data = {
                'user_id': str(user_id),
                'message': f"Te has unido al evento '{event.title}' en la comunidad '{event.community_id}'.",
                'event_id': str(event.id),
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            if join_all_recurrences and event.is_recurring():
                recurrences = event.get_recurring_event_instances(datetime.now() + timedelta(days=365))
                for recurrence_event_id in recurrences:
                    recurrence_event = self.get_event_by_id(recurrence_event_id)
                    if ObjectId(user_id) not in recurrence_event.attendees:
                        recurrence_event.attendees.append(ObjectId(user_id))
                        self.event_repository.update(recurrence_event)
        except ValueError as ve:
            current_app.logger.error(f"Error al unirse al evento: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al unirse al evento: {str(e)}")
            raise Exception("Error al unirse al evento")

    def leave_event(self, event_id, user_id):
        """Permite que un usuario abandone un evento."""
        try:
            event = self.get_event_by_id(event_id)
            if not event:
                raise ValueError("Evento no encontrado")

            if ObjectId(user_id) not in event.attendees:
                raise ValueError("El usuario no está inscrito en este evento.")

            event.attendees.remove(ObjectId(user_id))
            self.event_repository.update(event)

            # Notificar al usuario de que ha abandonado el evento
            notification_data = {
                'user_id': str(user_id),
                'message': f"Has abandonado el evento '{event.title}' en la comunidad '{event.community_id}'.",
                'event_id': str(event.id),
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)
        except ValueError as ve:
            current_app.logger.error(f"Error al abandonar el evento: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al abandonar el evento: {str(e)}")
            raise Exception("Error al abandonar el evento")

    def confirm_rsvp(self, event_id, user_id):
        """Confirma la asistencia (RSVP) de un usuario a un evento."""
        try:
            event = self.get_event_by_id(event_id)
            if not event:
                raise ValueError("Evento no encontrado")

            if ObjectId(user_id) not in event.rsvp_list:
                event.rsvp_list.append(ObjectId(user_id))
                self.event_repository.update(event)

                # Notificar al usuario sobre la confirmación de RSVP
                notification_data = {
                    'user_id': str(user_id),
                    'message': f"Has confirmado tu asistencia al evento '{event.title}' en la comunidad '{event.community_id}'.",
                    'event_id': str(event.id),
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)
            else:
                raise ValueError("RSVP ya fue confirmado para este evento.")
        except ValueError as ve:
            current_app.logger.error(f"Error al confirmar RSVP: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al confirmar RSVP: {str(e)}")
            raise Exception("Error al confirmar RSVP")

    def cancel_rsvp(self, event_id, user_id):
        """Cancela la asistencia (RSVP) de un usuario a un evento."""
        try:
            event = self.get_event_by_id(event_id)
            if not event:
                raise ValueError("Evento no encontrado")

            if ObjectId(user_id) in event.rsvp_list:
                event.rsvp_list.remove(ObjectId(user_id))
                self.event_repository.update(event)

                # Notificar al usuario sobre la cancelación de RSVP
                notification_data = {
                    'user_id': str(user_id),
                    'message': f"Has cancelado tu asistencia al evento '{event.title}' en la comunidad '{event.community_id}'.",
                    'event_id': str(event.id),
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)
            else:
                raise ValueError("No se encontró RSVP confirmado para este usuario en este evento.")
        except ValueError as ve:
            current_app.logger.error(f"Error al cancelar RSVP: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al cancelar RSVP: {str(e)}")
            raise Exception("Error al cancelar RSVP")

    def get_public_events(self, page=1, per_page=10):
        """Obtiene los eventos públicos con paginación."""
        try:
            return self.event_repository.get_by_visibility("public", page=page, per_page=per_page)
        except Exception as e:
            current_app.logger.error(f"Error al obtener eventos públicos: {str(e)}")
            raise Exception("Error al obtener eventos públicos")

    def add_rating(self, event_id, user_id, rating):
        """Añade una calificación a un evento."""
        try:
            if rating < 0 or rating > 5:
                raise ValueError("La calificación debe estar entre 0 y 5")

            event = self.get_event_by_id(event_id)
            if not event:
                raise ValueError("Evento no encontrado")

            event.update_rating(user_id, rating)
            self.event_repository.update(event)
        except ValueError as ve:
            current_app.logger.error(f"Error al calificar evento: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al calificar evento: {str(e)}")
            raise Exception("Error al calificar evento")
