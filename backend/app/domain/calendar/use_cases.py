# relative path: app/domain/calendar/use_cases.py

from marshmallow import ValidationError
from .repositories import CalendarRepository
from .entities import CalendarSchema

class CalendarUseCases:
    """Clase que define los casos de uso para la entidad Calendar."""

    def __init__(self, db):
        self.calendar_repository = CalendarRepository(db)
        self.calendar_schema = CalendarSchema()

    def create_calendar(self, calendar_data):
        """Crea un nuevo calendario."""
        try:
            # Validar los datos del calendario utilizando Marshmallow
            validated_data = self.calendar_schema.load(calendar_data)
            calendar_id = self.calendar_repository.create_calendar(validated_data)
            return calendar_id
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def update_calendar(self, user_id, calendar_id, new_data):
        """Actualiza los detalles de un calendario, verificando si el usuario es el propietario."""
        try:
            # Obtener los detalles del calendario
            calendar = self.calendar_repository.get_calendar_by_id(calendar_id)
            if not calendar:
                return {"error": "Calendario no encontrado"}

            # Verificar si el usuario es el propietario del calendario
            if calendar['owner'] != user_id:
                return {"error": "No tienes permisos para actualizar este calendario"}

            # Validar los nuevos datos del calendario
            validated_data = self.calendar_schema.load(new_data, partial=True)
            updated = self.calendar_repository.update_calendar(calendar_id, validated_data)
            if updated:
                return {"message": "Calendario actualizado exitosamente"}
            return {"error": "Error al actualizar el calendario"}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def delete_calendar(self, user_id, calendar_id):
        """Elimina un calendario verificando si el usuario es el propietario."""
        try:
            # Obtener los detalles del calendario
            calendar = self.calendar_repository.get_calendar_by_id(calendar_id)
            if not calendar:
                return {"error": "Calendario no encontrado"}

            # Verificar si el usuario es el propietario del calendario
            if calendar['owner'] != user_id:
                return {"error": "No tienes permisos para eliminar este calendario"}

            # Proceder a eliminar
            deleted = self.calendar_repository.delete_calendar(calendar_id)
            if deleted:
                return {"message": "Calendario eliminado exitosamente"}
            return {"error": "Error al eliminar el calendario"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_calendar_details(self, calendar_id):
        """Obtiene los detalles de un calendario."""
        try:
            calendar = self.calendar_repository.get_calendar_by_id(calendar_id)
            if calendar:
                return calendar
            return {"error": "Calendario no encontrado"}
        except Exception as ex:
            return {"error": str(ex)}

    def add_event_to_calendar(self, user_id, calendar_id, event_id):
        """Añade un evento a un calendario verificando si el usuario es el propietario."""
        try:
            # Obtener los detalles del calendario
            calendar = self.calendar_repository.get_calendar_by_id(calendar_id)
            if not calendar:
                return {"error": "Calendario no encontrado"}

            # Verificar si el usuario es el propietario del calendario
            if calendar['owner'] != user_id:
                return {"error": "No tienes permisos para añadir eventos a este calendario"}

            added = self.calendar_repository.add_event_to_calendar(calendar_id, event_id)
            if added:
                return {"message": "Evento añadido exitosamente al calendario"}
            return {"error": "Error al añadir el evento al calendario"}
        except Exception as ex:
            return {"error": str(ex)}

    def remove_event_from_calendar(self, user_id, calendar_id, event_id):
        """Elimina un evento de un calendario verificando si el usuario es el propietario."""
        try:
            # Obtener los detalles del calendario
            calendar = self.calendar_repository.get_calendar_by_id(calendar_id)
            if not calendar:
                return {"error": "Calendario no encontrado"}

            # Verificar si el usuario es el propietario del calendario
            if calendar['owner'] != user_id:
                return {"error": "No tienes permisos para eliminar eventos de este calendario"}

            removed = self.calendar_repository.remove_event_from_calendar(calendar_id, event_id)
            if removed:
                return {"message": "Evento eliminado exitosamente del calendario"}
            return {"error": "Error al eliminar el evento del calendario"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_public_calendars(self, page=1, limit=10):
        """Lista los calendarios públicos con paginación."""
        try:
            calendars = self.calendar_repository.get_public_calendars(page, limit)
            return calendars
        except Exception as ex:
            return {"error": str(ex)}

    def share_calendar(self, calendar_id):
        """Genera una URL pública para compartir un calendario."""
        try:
            shared_url = self.calendar_repository.share_calendar(calendar_id)
            if shared_url:
                return {"shared_url": shared_url}
            return {"error": "Error al generar la URL pública"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_calendar_subscribers(self, calendar_id):
        """Lista los suscriptores de un calendario."""
        try:
            subscribers = self.calendar_repository.get_subscribers(calendar_id)
            return subscribers
        except Exception as ex:
            return {"error": str(ex)}

    def set_event_reminder(self, user_id, calendar_id, event_id, reminder_data):
        """Configura un recordatorio personalizado para un evento verificando si el usuario es el propietario."""
        try:
            # Obtener los detalles del calendario
            calendar = self.calendar_repository.get_calendar_by_id(calendar_id)
            if not calendar:
                return {"error": "Calendario no encontrado"}

            # Verificar si el usuario es el propietario del calendario
            if calendar['owner'] != user_id:
                return {"error": "No tienes permisos para configurar recordatorios en este calendario"}

            reminder_set = self.calendar_repository.set_event_reminder(calendar_id, event_id, reminder_data)
            if reminder_set:
                return {"message": "Recordatorio configurado exitosamente"}
            return {"error": "Error al configurar el recordatorio"}
        except Exception as ex:
            return {"error": str(ex)}
