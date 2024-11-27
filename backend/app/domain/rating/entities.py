# relative path: app/domain/rating/entities.py

import uuid
from datetime import datetime
from marshmallow import Schema, fields, validate, validates, ValidationError

class Rating:
    """Clase que representa una puntuación de un usuario hacia un evento."""

    def __init__(self, event, user, score):
        self.id = str(uuid.uuid4())
        self.event = event  # UUID del evento puntuado
        self.user = user  # UUID del usuario que dio la puntuación
        self.score = score
        self.created_at = datetime.utcnow()

class RatingSchema(Schema):
    """Esquema de validación y serialización de Rating utilizando Marshmallow."""
    
    id = fields.UUID(dump_only=True)
    event = fields.String(required=True)  # UUID del evento puntuado
    user = fields.String(required=True)  # UUID del usuario que dejó la puntuación
    score = fields.Integer(required=True, validate=validate.Range(min=1, max=5))  # Puntuación de 1 a 5
    created_at = fields.DateTime(dump_only=True)

    @validates('event')
    def validate_event_exists(self, event, **kwargs):
        """Valida que el evento exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.events.find_one({"_id": event}):
            raise ValidationError(f"El evento con ID {event} no existe.")
    
    @validates('user')
    def validate_user_exists(self, user, **kwargs):
        """Valida que el usuario que deja la puntuación exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.users.find_one({"_id": user}):
            raise ValidationError(f"El usuario con ID {user} no existe.")
    
    @validates('score')
    def validate_unique_rating(self, score, **kwargs):
        """Valida que el usuario no haya puntuado el mismo evento más de una vez."""
        db = kwargs.get('db_instance')
        event = kwargs.get('event_id')
        user = kwargs.get('user_id')
        existing_rating = db.ratings.find_one({"event": event, "user": user})
        if existing_rating:
            raise ValidationError(f"El usuario con ID {user} ya ha puntuado el evento con ID {event}.")
