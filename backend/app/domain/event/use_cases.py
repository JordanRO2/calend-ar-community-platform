# relative path: app/domain/event/use_cases.py

from marshmallow import ValidationError
from .repositories import EventRepository
from .entities import EventSchema

class EventUseCases:
    """Clase que define los casos de uso para la entidad Event."""

    def __init__(self, db):
        self.event_repository = EventRepository(db)
        self.event_schema = EventSchema()

    def create_event(self, event_data):
        """Crea un nuevo evento."""
        try:
            # Validar los datos del evento utilizando Marshmallow
            validated_data = self.event_schema.load(event_data)
            event_id = self.event_repository.create_event(validated_data)
            return event_id
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def update_event(self, event_id, new_data):
        """Actualiza los detalles de un evento."""
        try:
            # Validar los nuevos datos del evento
            validated_data = self.event_schema.load(new_data, partial=True)
            updated = self.event_repository.update_event(event_id, validated_data)
            if updated:
                return {"message": "Evento actualizado exitosamente"}
            return {"error": "Error al actualizar el evento"}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def delete_event(self, event_id):
        """Elimina un evento."""
        try:
            deleted = self.event_repository.delete_event(event_id)
            if deleted:
                return {"message": "Evento eliminado exitosamente"}
            return {"error": "Error al eliminar el evento"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_event_details(self, event_id):
        """Obtiene los detalles de un evento."""
        try:
            event = self.event_repository.get_event_by_id(event_id)
            if event:
                return event
            return {"error": "Evento no encontrado"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_event_attendees(self, event_id, page=1, limit=10):
        """Lista los asistentes de un evento."""
        try:
            attendees = self.event_repository.get_event_attendees(event_id, page, limit)
            return attendees
        except Exception as ex:
            return {"error": str(ex)}

    def add_attendee_to_event(self, event_id, user_id):
        """Añade un asistente a un evento."""
        try:
            added = self.event_repository.add_attendee(event_id, user_id)
            if added:
                return {"message": "Asistencia registrada exitosamente"}
            return {"error": "Error al registrar la asistencia"}
        except Exception as ex:
            return {"error": str(ex)}

    def remove_attendee_from_event(self, event_id, user_id):
        """Elimina un asistente de un evento."""
        try:
            removed = self.event_repository.remove_attendee(event_id, user_id)
            if removed:
                return {"message": "Asistencia eliminada exitosamente"}
            return {"error": "Error al eliminar la asistencia"}
        except Exception as ex:
            return {"error": str(ex)}

    def mark_event_as_featured(self, event_id):
        """Marca un evento como destacado."""
        try:
            updated = self.event_repository.update_event(event_id, {'featured': True})
            if updated:
                return {"message": "Evento marcado como destacado exitosamente"}
            return {"error": "Error al marcar el evento como destacado"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_featured_events(self, page=1, limit=10):
        """Obtiene una lista paginada de eventos destacados."""
        try:
            featured_events = self.event_repository.get_featured_events(page, limit)
            return featured_events
        except Exception as ex:
            return {"error": str(ex)}

    def filter_events(self, filters, page=1, limit=10):
        """Filtra los eventos basados en los criterios especificados."""
        try:
            filtered_events = self.event_repository.filter_events(filters, page, limit)
            return filtered_events
        except Exception as ex:
            return {"error": str(ex)}

    def manage_recurrence(self, event_id, recurrence_data):
        """Maneja la recurrencia de un evento."""
        try:
            updated = self.event_repository.manage_event_recurrence(event_id, recurrence_data)
            if updated:
                return {"message": "Recurrencia del evento actualizada exitosamente"}
            return {"error": "Error al actualizar la recurrencia del evento"}
        except Exception as ex:
            return {"error": str(ex)}

    def cancel_event(self, event_id):
        """Cancela un evento."""
        try:
            canceled = self.event_repository.cancel_event(event_id)
            if canceled:
                return {"message": "Evento cancelado exitosamente"}
            return {"error": "Error al cancelar el evento"}
        except Exception as ex:
            return {"error": str(ex)}
