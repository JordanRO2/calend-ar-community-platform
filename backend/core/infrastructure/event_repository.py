from bson import ObjectId
from flask import current_app
from core.domain.event import Event
from datetime import datetime

class EventRepository:
    def __init__(self, db):
        self.events = db.events

    def get_by_id(self, event_id):
        try:
            event_data = self.events.find_one({'_id': ObjectId(event_id)})
            if event_data:
                event_data['id'] = str(event_data.pop('_id'))
                return Event.from_dict(event_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener evento por ID {event_id}: {str(e)}")
            raise Exception("Error al obtener el evento")

    def get_all(self, page=1, per_page=10, visibility=None):
        try:
            query = {}
            if visibility:
                query['visibility'] = visibility
            event_list = []
            cursor = self.events.find(query).skip((page - 1) * per_page).limit(per_page)
            for event_data in cursor:
                event_data['id'] = str(event_data.pop('_id'))
                event_list.append(Event.from_dict(event_data))
            return event_list
        except Exception as e:
            current_app.logger.error(f"Error al obtener eventos: {str(e)}")
            raise Exception("Error al obtener eventos")

    def create(self, event):
        try:
            event_dict = event.to_dict()
            event_dict['_id'] = ObjectId(event_dict.pop('id'))  # MongoDB maneja _id
            self.events.insert_one(event_dict)
            current_app.logger.info(f"Evento '{event.title}' creado exitosamente.")
        except Exception as e:
            current_app.logger.error(f"Error al crear evento: {str(e)}")
            raise Exception("Error al crear el evento")

    def update(self, event):
        try:
            event_dict = event.to_dict()
            event_dict['_id'] = ObjectId(event_dict.pop('id'))  # Convertir 'id' a ObjectId
            result = self.events.update_one({'_id': ObjectId(event.id)}, {'$set': event_dict})
            if result.matched_count == 0:
                raise ValueError("Evento no encontrado")
            current_app.logger.info(f"Evento '{event.title}' actualizado exitosamente.")
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar evento {event.id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar evento {event.id}: {str(e)}")
            raise Exception("Error al actualizar evento")

    def delete(self, event_id):
        try:
            result = self.events.delete_one({'_id': ObjectId(event_id)})
            if result.deleted_count == 0:
                raise ValueError("Evento no encontrado")
            current_app.logger.info(f"Evento con ID '{event_id}' eliminado exitosamente.")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar evento {event_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar evento {event_id}: {str(e)}")
            raise Exception("Error al eliminar el evento")

    # Obtener eventos destacados
    def get_featured(self, page=1, per_page=5):
        try:
            event_list = []
            cursor = self.events.find({'featured': True}).sort('rating_score', -1).skip((page - 1) * per_page).limit(per_page)
            for event_data in cursor:
                event_data['id'] = str(event_data.pop('_id'))
                event_list.append(Event.from_dict(event_data))
            return event_list
        except Exception as e:
            current_app.logger.error(f"Error al obtener eventos destacados: {str(e)}")
            raise Exception("Error al obtener eventos destacados")

    # Manejo de asistentes (attendees)
    def add_attendee(self, event_id, user_id):
        try:
            result = self.events.update_one(
                {'_id': ObjectId(event_id)},
                {'$addToSet': {'attendees': ObjectId(user_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Evento con ID {event_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al agregar asistente al evento {event_id}: {str(e)}")
            raise Exception("Error al agregar asistente al evento")

    def remove_attendee(self, event_id, user_id):
        try:
            result = self.events.update_one(
                {'_id': ObjectId(event_id)},
                {'$pull': {'attendees': ObjectId(user_id)}}  # Eliminar asistente
            )
            if result.matched_count == 0:
                raise ValueError(f"Evento con ID {event_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al remover asistente del evento {event_id}: {str(e)}")
            raise Exception("Error al remover asistente del evento")

    # RSVP handling: agregar un usuario a la lista de RSVP
    def add_rsvp(self, event_id, user_id):
        try:
            result = self.events.update_one(
                {'_id': ObjectId(event_id)},
                {'$addToSet': {'rsvp_list': ObjectId(user_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Evento con ID {event_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al agregar RSVP al evento {event_id}: {str(e)}")
            raise Exception("Error al agregar RSVP al evento")

    # Remover un usuario de la lista de RSVP
    def remove_rsvp(self, event_id, user_id):
        try:
            result = self.events.update_one(
                {'_id': ObjectId(event_id)},
                {'$pull': {'rsvp_list': ObjectId(user_id)}}  # Remover usuario de RSVP
            )
            if result.matched_count == 0:
                raise ValueError(f"Evento con ID {event_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al remover RSVP del evento {event_id}: {str(e)}")
            raise Exception("Error al remover RSVP del evento")

    # Actualización de calificaciones del evento
    def update_rating(self, event_id, user_id, rating_value):
        try:
            # Verifica si el usuario ya ha calificado el evento
            result = self.events.update_one(
                {'_id': ObjectId(event_id), f'ratings.{user_id}': {'$exists': True}},
                {'$set': {f'ratings.{user_id}': rating_value}}
            )
            if result.matched_count == 0:  # Si el usuario no ha calificado previamente, añade el rating
                self.events.update_one(
                    {'_id': ObjectId(event_id)},
                    {'$set': {f'ratings.{user_id}': rating_value}}
                )
            current_app.logger.info(f"Calificación actualizada para el evento {event_id} por usuario {user_id}")
        except Exception as e:
            current_app.logger.error(f"Error al actualizar calificación del evento {event_id}: {str(e)}")
            raise Exception(f"Error al actualizar calificación del evento {event_id}")

    # Obtener instancias de eventos recurrentes
    def get_recurring_events(self, event_id, end_date):
        try:
            event = self.get_by_id(event_id)
            if event and event.is_recurring():
                recurrences = event.get_recurring_event_instances(end_date)
                return recurrences
            return []
        except Exception as e:
            current_app.logger.error(f"Error al obtener eventos recurrentes para el evento {event_id}: {str(e)}")
            raise Exception("Error al obtener eventos recurrentes")
