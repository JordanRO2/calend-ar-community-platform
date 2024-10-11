from datetime import datetime, timedelta
from flask import current_app
from core.domain.calendar import Calendar
from core.domain.notification import NotificationStatus

class CalendarService:
    def __init__(self, calendar_repository, event_service, notification_service):
        self.calendar_repository = calendar_repository
        self.event_service = event_service
        self.notification_service = notification_service  # Conectar también con el servicio de notificaciones

    def get_calendar_by_id(self, calendar_id):
        """Obtiene un calendario por su ID."""
        try:
            calendar = self.calendar_repository.get_by_id(calendar_id)
            if not calendar:
                raise ValueError("Calendario no encontrado")
            return calendar
        except ValueError as ve:
            current_app.logger.error(f"Error al obtener calendario {calendar_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error inesperado al obtener calendario {calendar_id}: {str(e)}")
            raise Exception("Error inesperado al obtener el calendario")

    def create_calendar(self, calendar_data):
        """Crea un nuevo calendario."""
        try:
            calendar = Calendar(**calendar_data)
            self.calendar_repository.create(calendar)

            # Notificar al propietario del calendario
            notification_data = {
                'user_id': str(calendar.owner_id),
                'message': f"Se ha creado un nuevo calendario '{calendar.name}'.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir actualización en tiempo real a través de websockets
            current_app.socketio.emit('calendar_created', calendar.to_dict(), room=str(calendar.owner_id))

            return calendar
        except Exception as e:
            current_app.logger.error(f"Error al crear calendario: {str(e)}")
            raise Exception("Error al crear el calendario")

    def update_calendar(self, calendar_id, calendar_data):
        """Actualiza un calendario existente."""
        try:
            calendar = self.get_calendar_by_id(calendar_id)
            if not calendar:
                raise ValueError("Calendario no encontrado")
                
            calendar.update(calendar_data)
            self.calendar_repository.update(calendar)

            # Notificar al propietario del calendario
            notification_data = {
                'user_id': str(calendar.owner_id),
                'message': f"Tu calendario '{calendar.name}' ha sido actualizado.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir actualización en tiempo real para el calendario actualizado
            current_app.socketio.emit('calendar_updated', calendar.to_dict(), room=str(calendar.owner_id))

            return calendar
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar calendario {calendar_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error inesperado al actualizar calendario {calendar_id}: {str(e)}")
            raise Exception("Error inesperado al actualizar el calendario")

    def add_event_to_calendar(self, calendar_id, event_id, add_all_recurrences=False):
        """Añade un evento al calendario, con la opción de agregar todas las recurrencias."""
        try:
            calendar = self.get_calendar_by_id(calendar_id)
            if not calendar:
                raise ValueError("Calendario no encontrado")

            # Verificar si el evento es recurrente y si se debe agregar todas las recurrencias
            if add_all_recurrences and self.event_service.is_recurring_event(event_id):
                recurring_events = self.event_service.get_recurring_event_instances(event_id, datetime.now() + timedelta(days=365))
                for recurring_event_id in recurring_events:
                    calendar.add_event(recurring_event_id, self.event_service, add_all_recurrences=False)
            else:
                # Agregar solo el evento actual
                calendar.add_event(event_id, self.event_service, add_all_recurrences=False)

            self.calendar_repository.update(calendar)

            # Notificar al propietario del calendario
            notification_data = {
                'user_id': str(calendar.owner_id),
                'message': f"Se ha añadido un evento a tu calendario '{calendar.name}'.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir actualización en tiempo real para eventos añadidos
            current_app.socketio.emit('event_added_to_calendar', {
                'calendar_id': str(calendar.id),
                'event_id': str(event_id)
            }, room=str(calendar.owner_id))

            return calendar
        except ValueError as ve:
            current_app.logger.error(f"Error al agregar evento {event_id} al calendario {calendar_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error inesperado al agregar evento {event_id} al calendario {calendar_id}: {str(e)}")
            raise Exception("Error inesperado al agregar evento al calendario")

    def delete_calendar(self, calendar_id):
        """Elimina un calendario por su ID."""
        try:
            calendar = self.get_calendar_by_id(calendar_id)
            if not calendar:
                raise ValueError("Calendario no encontrado")

            self.calendar_repository.delete(calendar_id)
            current_app.logger.info(f"Calendario {calendar_id} eliminado correctamente.")

            # Notificar al propietario sobre la eliminación del calendario
            notification_data = {
                'user_id': str(calendar.owner_id),
                'message': f"Tu calendario '{calendar.name}' ha sido eliminado.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir eliminación en tiempo real
            current_app.socketio.emit('calendar_deleted', {'calendar_id': str(calendar_id)}, room=str(calendar.owner_id))
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar calendario {calendar_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error inesperado al eliminar calendario {calendar_id}: {str(e)}")
            raise Exception("Error inesperado al eliminar el calendario")

    def change_owner(self, calendar_id, new_owner_id, is_user_calendar):
        """Cambia el propietario de un calendario."""
        try:
            calendar = self.get_calendar_by_id(calendar_id)
            if not calendar:
                raise ValueError("Calendario no encontrado")

            calendar.change_owner(new_owner_id, is_user_calendar)
            self.calendar_repository.update(calendar)
            current_app.logger.info(f"Propietario del calendario {calendar_id} actualizado correctamente.")

            # Notificar al nuevo propietario del calendario
            notification_data = {
                'user_id': str(new_owner_id),
                'message': f"Ahora eres el propietario del calendario '{calendar.name}'.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            # Emitir actualización en tiempo real para el cambio de propietario
            current_app.socketio.emit('calendar_owner_changed', {
                'calendar_id': str(calendar.id),
                'new_owner_id': str(new_owner_id)
            }, room=str(new_owner_id))

        except ValueError as ve:
            current_app.logger.error(f"Error al cambiar propietario del calendario {calendar_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error inesperado al cambiar propietario del calendario {calendar_id}: {str(e)}")
            raise Exception("Error inesperado al cambiar propietario del calendario")

    def get_event_instances(self, calendar_id, end_date):
        """Obtiene las instancias de eventos recurrentes hasta la fecha de finalización."""
        try:
            calendar = self.get_calendar_by_id(calendar_id)
            if not calendar:
                raise ValueError("Calendario no encontrado")

            event_instances = calendar.get_event_instances(self.event_service, end_date)
            return event_instances
        except ValueError as ve:
            current_app.logger.error(f"Error al obtener instancias de eventos para el calendario {calendar_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error inesperado al obtener instancias de eventos para el calendario {calendar_id}: {str(e)}")
            raise Exception("Error inesperado al obtener instancias de eventos")
