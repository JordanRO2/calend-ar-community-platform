from bson import ObjectId
from flask import current_app
from core.domain.calendar import Calendar

class CalendarRepository:
    def __init__(self, db):
        self.calendars = db.calendars  # Colección de calendarios en MongoDB

    def get_by_id(self, calendar_id):
        """Obtiene un calendario por su ID."""
        try:
            calendar_data = self.calendars.find_one({'_id': ObjectId(calendar_id)})
            if calendar_data:
                calendar_data['id'] = str(calendar_data.pop('_id'))  # Convertir ObjectId a string
                return Calendar.from_dict(calendar_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener calendario {calendar_id}: {str(e)}")
            raise Exception("Error al obtener el calendario")

    def get_by_owner_id(self, owner_id):
        """Obtiene un calendario por el ID del propietario."""
        try:
            calendar_data = self.calendars.find_one({'owner_id': ObjectId(owner_id)})
            if calendar_data:
                calendar_data['id'] = str(calendar_data.pop('_id'))  # Convertir ObjectId a string
                return Calendar.from_dict(calendar_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener calendario del propietario {owner_id}: {str(e)}")
            raise Exception("Error al obtener el calendario del propietario")

    def create(self, calendar):
        """Crea un nuevo calendario."""
        try:
            calendar_dict = calendar.to_dict()
            calendar_dict['_id'] = ObjectId(calendar_dict.pop('id'))
            self.calendars.insert_one(calendar_dict)
        except Exception as e:
            current_app.logger.error(f"Error al crear calendario: {str(e)}")
            raise Exception("Error al crear el calendario")

    def update(self, calendar):
        """Actualiza un calendario existente."""
        try:
            calendar_dict = calendar.to_dict()
            calendar_dict['_id'] = ObjectId(calendar_dict.pop('id'))
            result = self.calendars.update_one(
                {'_id': ObjectId(calendar.id)}, 
                {'$set': calendar_dict}
            )
            if result.matched_count == 0:
                raise ValueError("Calendario no encontrado")
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar calendario {calendar.id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar calendario {calendar.id}: {str(e)}")
            raise Exception("Error al actualizar el calendario")

    def delete(self, calendar_id):
        """Elimina un calendario por su ID."""
        try:
            result = self.calendars.delete_one({'_id': ObjectId(calendar_id)})
            if result.deleted_count == 0:
                raise ValueError("Calendario no encontrado")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar calendario {calendar_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error inesperado al eliminar calendario {calendar_id}: {str(e)}")
            raise Exception("Error inesperado al eliminar el calendario")

    def add_event(self, calendar_id, event_id, event_service=None, add_all_recurrences=False):
        """Añade un evento al calendario. Si es recurrente, añade todas las instancias."""
        try:
            calendar = self.get_by_id(calendar_id)
            if calendar:
                calendar.add_event(event_id, event_service, add_all_recurrences)
                self.update(calendar)
                current_app.logger.info(f"Evento {event_id} añadido al calendario {calendar_id}.")
            else:
                raise ValueError("Calendario no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al añadir evento {event_id} al calendario {calendar_id}: {str(e)}")
            raise Exception(f"Error al añadir evento {event_id} al calendario {calendar_id}")

    def remove_event(self, calendar_id, event_id):
        """Elimina un evento del calendario."""
        try:
            calendar = self.get_by_id(calendar_id)
            if calendar:
                calendar.remove_event(event_id)
                self.update(calendar)
                current_app.logger.info(f"Evento {event_id} eliminado del calendario {calendar_id}.")
            else:
                raise ValueError("Calendario no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar evento {event_id} del calendario {calendar_id}: {str(e)}")
            raise Exception(f"Error al eliminar evento {event_id} del calendario {calendar_id}")

    def change_owner(self, calendar_id, new_owner_id, is_user_calendar):
        """Cambia el propietario de un calendario."""
        try:
            calendar = self.get_by_id(calendar_id)
            if calendar:
                calendar.change_owner(new_owner_id, is_user_calendar)
                self.update(calendar)
                current_app.logger.info(f"Propietario del calendario {calendar_id} cambiado a {new_owner_id}.")
            else:
                raise ValueError("Calendario no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al cambiar el propietario del calendario {calendar_id}: {str(e)}")
            raise Exception(f"Error al cambiar el propietario del calendario {calendar_id}")

    def get_event_instances(self, calendar_id, event_service, end_date):
        """Genera las instancias de eventos recurrentes hasta una fecha de finalización."""
        try:
            calendar = self.get_by_id(calendar_id)
            if calendar:
                event_instances = calendar.get_event_instances(event_service, end_date)
                current_app.logger.info(f"Se generaron {len(event_instances)} instancias de eventos recurrentes para el calendario {calendar_id}.")
                return event_instances
            raise ValueError("Calendario no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al obtener instancias de eventos para el calendario {calendar_id}: {str(e)}")
            raise Exception(f"Error al obtener instancias de eventos para el calendario {calendar_id}")
