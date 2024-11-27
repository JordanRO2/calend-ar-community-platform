# relative path: app/domain/calendar/repositories.py

from pymongo import MongoClient
from bson.objectid import ObjectId

class CalendarRepository:
    """Repositorio que maneja todas las operaciones CRUD relacionadas con los calendarios."""

    def __init__(self, db: MongoClient):
        self.calendars = db.calendars  # Colección de calendarios en MongoDB

    def create_calendar(self, data):
        """Crea un nuevo calendario en la base de datos, asegurando que no exista un duplicado."""
        # Verificar si ya existe un calendario con el mismo nombre y propietario
        existing_calendar = self.calendars.find_one({'name': data['name'], 'owner': data['owner']})
        if existing_calendar:
            return {"error": "Ya existe un calendario con este nombre para el mismo propietario."}

        # Insertar el nuevo calendario si no hay duplicados
        result = self.calendars.insert_one(data)
        return str(result.inserted_id)

    def update_calendar(self, calendar_id, data):
        """Actualiza los detalles de un calendario si existe."""
        # Verificar si el calendario existe
        existing_calendar = self.get_calendar_by_id(calendar_id)
        if not existing_calendar:
            return {"error": "El calendario no existe."}

        # Actualizar el calendario
        result = self.calendars.update_one({'_id': ObjectId(calendar_id)}, {'$set': data})
        return result.modified_count > 0

    def delete_calendar(self, calendar_id):
        """Elimina un calendario de la base de datos si existe."""
        # Verificar si el calendario existe antes de eliminarlo
        existing_calendar = self.get_calendar_by_id(calendar_id)
        if not existing_calendar:
            return {"error": "El calendario no existe."}

        result = self.calendars.delete_one({'_id': ObjectId(calendar_id)})
        return result.deleted_count > 0

    def get_calendar_by_id(self, calendar_id):
        """Obtiene un calendario por su ID."""
        try:
            calendar = self.calendars.find_one({'_id': ObjectId(calendar_id)})
            if calendar:
                calendar['_id'] = str(calendar['_id'])
            return calendar
        except Exception:
            return {"error": "Formato de ID no válido."}

    def get_all_calendars(self, page=1, limit=10):
        """Obtiene una lista paginada de todos los calendarios."""
        skip = (page - 1) * limit
        calendars = self.calendars.find().skip(skip).limit(limit)
        return [{'_id': str(calendar['_id']), **calendar} for calendar in calendars]

    def add_event_to_calendar(self, calendar_id, event_id):
        """Agrega un evento a un calendario si el calendario y el evento no están ya relacionados."""
        # Verificar si el calendario existe
        existing_calendar = self.get_calendar_by_id(calendar_id)
        if not existing_calendar:
            return {"error": "El calendario no existe."}

        # Verificar si el evento ya está en el calendario
        if event_id in existing_calendar.get('events', []):
            return {"error": "El evento ya está en el calendario."}

        # Agregar el evento
        result = self.calendars.update_one(
            {'_id': ObjectId(calendar_id)},
            {'$addToSet': {'events': event_id}}
        )
        return result.modified_count > 0

    def remove_event_from_calendar(self, calendar_id, event_id):
        """Elimina un evento de un calendario si existe."""
        # Verificar si el calendario existe
        existing_calendar = self.get_calendar_by_id(calendar_id)
        if not existing_calendar:
            return {"error": "El calendario no existe."}

        # Eliminar el evento del calendario
        result = self.calendars.update_one(
            {'_id': ObjectId(calendar_id)},
            {'$pull': {'events': event_id}}
        )
        return result.modified_count > 0

    def get_public_calendars(self, page=1, limit=10):
        """Devuelve una lista de calendarios públicos."""
        skip = (page - 1) * limit
        public_calendars = self.calendars.find({'is_public': True}).skip(skip).limit(limit)
        return [{'_id': str(calendar['_id']), **calendar} for calendar in public_calendars]

    def share_calendar(self, calendar_id):
        """Genera una URL compartida para el calendario si existe."""
        # Verificar si el calendario existe
        existing_calendar = self.get_calendar_by_id(calendar_id)
        if not existing_calendar:
            return {"error": "El calendario no existe."}

        # Generar y actualizar la URL compartida
        shared_url = f'/calendars/{calendar_id}/share'
        result = self.calendars.update_one(
            {'_id': ObjectId(calendar_id)},
            {'$set': {'shared_url': shared_url}}
        )
        return shared_url if result.modified_count > 0 else None

    def get_subscribers(self, calendar_id):
        """Devuelve la lista de usuarios suscritos a un calendario."""
        calendar = self.get_calendar_by_id(calendar_id)
        return calendar.get('subscribers', []) if calendar else {"error": "El calendario no existe."}

    def set_event_reminder(self, calendar_id, event_id, reminder_data):
        """Configura recordatorios personalizados para eventos si el evento existe en el calendario."""
        # Verificar si el calendario y el evento existen
        calendar = self.get_calendar_by_id(calendar_id)
        if not calendar:
            return {"error": "El calendario no existe."}

        if event_id not in calendar.get('events', []):
            return {"error": "El evento no está en el calendario."}

        # Configurar el recordatorio
        result = self.calendars.update_one(
            {'_id': ObjectId(calendar_id), 'events': event_id},
            {'$set': {'reminders': reminder_data}}
        )
        return result.modified_count > 0
