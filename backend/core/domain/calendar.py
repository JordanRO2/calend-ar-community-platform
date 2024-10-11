from bson import ObjectId
from datetime import datetime, timezone

class Calendar:
    def __init__(self, id=None, owner_id=None, events=None, custom_color_scheme=None, is_user_calendar=True):
        self.id = ObjectId() if id is None else ObjectId(id)
        self.owner_id = ObjectId(owner_id)  # ID del usuario o comunidad propietario del calendario
        self.events = events or []  # Lista de IDs de eventos
        self.custom_color_scheme = custom_color_scheme  # Opcional: esquema de color personalizado
        self.is_user_calendar = is_user_calendar  # True si es calendario de usuario, False si es de comunidad
        self.created_at = datetime.now(timezone.utc)  # Fecha de creación
        self.updated_at = datetime.now(timezone.utc)  # Fecha de última actualización

    def to_dict(self):
        """Convierte el objeto Calendar a un diccionario."""
        return {
            'id': str(self.id),
            'owner_id': str(self.owner_id),
            'events': [str(event) for event in self.events],  # Convertir a string
            'custom_color_scheme': self.custom_color_scheme,
            'is_user_calendar': self.is_user_calendar,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
        }

    def update(self, data):
        """Actualiza los atributos del calendario."""
        self.custom_color_scheme = data.get('custom_color_scheme', self.custom_color_scheme)
        self.updated_at = datetime.now(timezone.utc)
        if 'events' in data:
            self.events = [ObjectId(event_id) for event_id in data['events']]

    def add_event(self, event_id, event_service=None, add_all_recurrences=False):
        """Añade un evento al calendario. Si es un evento recurrente, añade todas las instancias."""
        event_id = ObjectId(event_id)
        if event_id not in self.events:
            self.events.append(event_id)

        # Si es un evento recurrente, añadimos todas las instancias
        if add_all_recurrences and event_service:
            recurrences = event_service.get_recurring_event_instances(event_id)
            for recurrence in recurrences:
                if recurrence not in self.events:
                    self.events.append(recurrence)
        self.updated_at = datetime.now(timezone.utc)

    def remove_event(self, event_id):
        """Elimina un evento del calendario."""
        event_id = ObjectId(event_id)
        if event_id in self.events:
            self.events.remove(event_id)
        self.updated_at = datetime.now(timezone.utc)

    def change_owner(self, new_owner_id, is_user_calendar):
        """Cambia el propietario del calendario."""
        self.owner_id = ObjectId(new_owner_id)
        self.is_user_calendar = is_user_calendar
        self.updated_at = datetime.now(timezone.utc)

    def get_event_instances(self, event_service, end_date):
        """Genera las instancias de eventos recurrentes hasta una fecha de finalización."""
        instances = []
        for event_id in self.events:
            event_instances = event_service.get_recurring_event_instances(event_id, end_date)
            instances.extend(event_instances)
        return instances
