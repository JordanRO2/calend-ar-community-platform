from bson import ObjectId
from datetime import datetime, timedelta

class Event:
    def __init__(self, id=None, community_id=None, title=None, description=None, date=None, location=None, images=None, attendees=None, rsvp_list=None, visibility="private", tags=None, featured=False, ratings=None, rating_score=0.0, recurrence_rule=None):
        self.id = ObjectId() if id is None else ObjectId(id)
        self.community_id = ObjectId(community_id)
        self.title = title
        self.description = description
        self.date = date
        self.location = location
        self.images = images or []
        self.attendees = attendees or []  # Lista de IDs de usuarios que asistieron al evento
        self.rsvp_list = rsvp_list or []  # Lista de IDs de usuarios que confirmaron asistencia
        self.visibility = visibility  # "public" o "private"
        self.tags = tags or []  # Categorías o etiquetas para filtrar eventos
        self.featured = featured  # Si el evento está destacado o no
        self.ratings = ratings or {}  # Diccionario {user_id: rating} para calificaciones de eventos (0-5)
        self.rating_score = self.calculate_rating() if ratings else rating_score  # Promedio de calificaciones
        self.recurrence_rule = recurrence_rule  # e.g., 'daily', 'weekly', etc. o None si no es recurrente
        self.created_at = datetime.now()  # Fecha de creación
        self.updated_at = datetime.now()  # Fecha de última actualización

    def to_dict(self):
        """Convierte el objeto Event a un diccionario."""
        return {
            'id': str(self.id),
            'community_id': str(self.community_id),
            'title': self.title,
            'description': self.description,
            'date': self.date.isoformat() if self.date else None,
            'location': self.location,
            'images': self.images,
            'attendees': [str(attendee) for attendee in self.attendees],  # Convertir ObjectId a string
            'rsvp_list': [str(rsvp) for rsvp in self.rsvp_list],  # Convertir ObjectId a string
            'visibility': self.visibility,
            'tags': self.tags,
            'featured': self.featured,
            'ratings': self.ratings,  # {user_id: rating}
            'rating_score': self.rating_score,  # Promedio de calificaciones
            'recurrence_rule': self.recurrence_rule,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
        }

    @staticmethod
    def from_dict(data):
        """Crea una instancia de Event a partir de un diccionario."""
        id = data.get('id')
        community_id = data.get('community_id')
        title = data.get('title')
        description = data.get('description')
        date_str = data.get('date')
        location = data.get('location')
        images = data.get('images', [])
        attendees = data.get('attendees', [])
        rsvp_list = data.get('rsvp_list', [])
        visibility = data.get('visibility', 'private')
        tags = data.get('tags', [])
        featured = data.get('featured', False)
        ratings = data.get('ratings', {})
        rating_score = data.get('rating_score', 0.0)
        recurrence_rule = data.get('recurrence_rule')

        if not community_id or not title or not description or not location:
            raise ValueError("Faltan campos obligatorios en los datos del evento.")

        date = datetime.fromisoformat(date_str) if date_str else None

        return Event(
            id=id,
            community_id=community_id,
            title=title,
            description=description,
            date=date,
            location=location,
            images=images,
            attendees=[ObjectId(attendee) for attendee in attendees],
            rsvp_list=[ObjectId(rsvp) for rsvp in rsvp_list],
            visibility=visibility,
            tags=tags,
            featured=featured,
            ratings=ratings,
            rating_score=rating_score,
            recurrence_rule=recurrence_rule
        )

    def is_recurring(self):
        """Verifica si el evento es recurrente en base a la regla de recurrencia."""
        return self.recurrence_rule is not None

    def get_recurring_event_instances(self, end_date):
        """Genera instancias de eventos recurrentes hasta la fecha final."""
        if not self.is_recurring() or not self.date:
            return []

        instances = []
        current_date = self.date
        while current_date <= end_date:
            instances.append(current_date)
            if self.recurrence_rule == 'daily':
                current_date += timedelta(days=1)
            elif self.recurrence_rule == 'weekly':
                current_date += timedelta(weeks=1)
            # Puedes añadir más reglas como monthly, yearly, etc.
        
        return instances

    def calculate_rating(self):
        """Calcula el puntaje promedio de calificación desde el diccionario de calificaciones."""
        if not self.ratings:
            return 0.0
        return sum(self.ratings.values()) / len(self.ratings)

    def update_rating(self, user_id, rating_value):
        """Actualiza la calificación del evento para un usuario y recalcula el puntaje promedio."""
        if rating_value < 0 or rating_value > 5:
            raise ValueError("La calificación debe estar entre 0 y 5.")
        self.ratings[str(user_id)] = rating_value
        self.rating_score = self.calculate_rating()
        self.updated_at = datetime.now()

    def feature_event(self):
        """Marca el evento como destacado."""
        self.featured = True
        self.updated_at = datetime.now()

    def unfeature_event(self):
        """Quita el evento de la lista de destacados."""
        self.featured = False
        self.updated_at = datetime.now()
