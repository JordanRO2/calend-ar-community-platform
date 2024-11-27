# relative path: app/domain/event/repositories.py

from pymongo import MongoClient
from bson.objectid import ObjectId

class EventRepository:
    """Repositorio que maneja todas las operaciones CRUD relacionadas con los eventos."""

    def __init__(self, db: MongoClient):
        self.events = db.events  # Colección de eventos en MongoDB

    def create_event(self, data):
        """Crea un nuevo evento en la base de datos."""
        # Validar si ya existe un evento con el mismo título y fecha en la comunidad
        existing_event = self.events.find_one({
            'title': data['title'],
            'date_time': data['date_time'],
            'community': data['community']
        })
        if existing_event:
            return {"error": "Ya existe un evento con el mismo título y fecha en esta comunidad."}
        
        result = self.events.insert_one(data)
        return str(result.inserted_id)

    def update_event(self, event_id, data):
        """Actualiza los detalles de un evento."""
        # Verificar si el evento existe
        if not self.get_event_by_id(event_id):
            return {"error": "El evento no existe."}

        result = self.events.update_one({'_id': ObjectId(event_id)}, {'$set': data})
        return result.modified_count > 0

    def delete_event(self, event_id):
        """Elimina un evento de la base de datos."""
        # Verificar si el evento existe
        if not self.get_event_by_id(event_id):
            return {"error": "El evento no existe."}

        result = self.events.delete_one({'_id': ObjectId(event_id)})
        return result.deleted_count > 0

    def get_event_by_id(self, event_id):
        """Obtiene un evento por su ID."""
        try:
            event = self.events.find_one({'_id': ObjectId(event_id)})
            if event:
                event['_id'] = str(event['_id'])
            return event
        except Exception:
            return {"error": "Formato de ID no válido."}

    def get_all_events(self, page=1, limit=10):
        """Obtiene una lista paginada de todos los eventos."""
        skip = (page - 1) * limit
        events = self.events.find().skip(skip).limit(limit)
        return [{'_id': str(event['_id']), **event} for event in events]

    def add_attendee(self, event_id, user_id):
        """Agrega un asistente al evento."""
        # Verificar si el evento existe
        event = self.get_event_by_id(event_id)
        if not event:
            return {"error": "El evento no existe."}

        # Verificar si el usuario ya es asistente
        if user_id in event.get('attendees', []):
            return {"error": "El usuario ya es asistente de este evento."}

        result = self.events.update_one(
            {'_id': ObjectId(event_id)},
            {'$addToSet': {'attendees': user_id}}
        )
        return result.modified_count > 0

    def remove_attendee(self, event_id, user_id):
        """Elimina un asistente del evento."""
        # Verificar si el evento existe
        event = self.get_event_by_id(event_id)
        if not event:
            return {"error": "El evento no existe."}

        # Verificar si el usuario es asistente
        if user_id not in event.get('attendees', []):
            return {"error": "El usuario no es asistente de este evento."}

        result = self.events.update_one(
            {'_id': ObjectId(event_id)},
            {'$pull': {'attendees': user_id}}
        )
        return result.modified_count > 0

    def get_event_attendees(self, event_id):
        """Devuelve la lista de asistentes a un evento."""
        event = self.get_event_by_id(event_id)
        return event.get('attendees', []) if event else {"error": "El evento no existe."}

    def get_featured_events(self, page=1, limit=10):
        """Devuelve una lista de eventos destacados."""
        skip = (page - 1) * limit
        featured_events = self.events.find({'featured': True}).skip(skip).limit(limit)
        return [{'_id': str(event['_id']), **event} for event in featured_events]

    def filter_events(self, filters, page=1, limit=10):
        """Filtra los eventos según los filtros proporcionados, con paginación."""
        query = {}
        if 'category' in filters:
            query['category'] = filters['category']
        if 'date' in filters:
            query['date_time'] = {'$gte': filters['date']}
        if 'popularity' in filters:
            query['popularity'] = {'$gte': filters['popularity']}
        
        skip = (page - 1) * limit
        events = self.events.find(query).skip(skip).limit(limit)
        return [{'_id': str(event['_id']), **event} for event in events]

    def manage_event_recurrence(self, event_id, recurrence_data):
        """Maneja la recurrencia de un evento."""
        # Verificar si el evento existe
        if not self.get_event_by_id(event_id):
            return {"error": "El evento no existe."}

        # Verificar si el evento ya tiene una recurrencia
        event = self.get_event_by_id(event_id)
        if event.get('is_recurring', False):
            return {"error": "El evento ya es recurrente."}

        result = self.events.update_one(
            {'_id': ObjectId(event_id)},
            {'$set': {'recurrence_pattern': recurrence_data['pattern'], 'recurrence_end': recurrence_data['end'], 'is_recurring': True}}
        )
        return result.modified_count > 0

    def cancel_event(self, event_id):
        """Cancela un evento actualizando su estado."""
        # Verificar si el evento existe
        if not self.get_event_by_id(event_id):
            return {"error": "El evento no existe."}

        result = self.events.update_one(
            {'_id': ObjectId(event_id)},
            {'$set': {'status': 'cancelled'}}
        )
        return result.modified_count > 0
