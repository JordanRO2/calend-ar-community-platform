# relative path: app/domain/comment/entities.py

import uuid
from datetime import datetime
from marshmallow import Schema, fields, validate, validates, ValidationError, validates_schema

class Comment:
    """Clase que representa un comentario dentro del sistema."""

    def __init__(self, user, event, content, likes=0, replies=None, report_count=0):
        self.id = str(uuid.uuid4())
        self.user = user  # UUID del usuario que hizo el comentario
        self.event = event  # UUID del evento relacionado
        self.content = content
        self.likes = likes
        self.replies = replies if replies is not None else []
        self.created_at = datetime.utcnow()
        self.report_count = report_count

class CommentSchema(Schema):
    """Esquema de validación y serialización de Comment utilizando Marshmallow."""
    
    id = fields.UUID(dump_only=True)
    user = fields.String(required=True)  # UUID del usuario
    event = fields.String(required=True)  # UUID del evento relacionado
    content = fields.String(required=True, validate=validate.Length(min=1, max=500))
    likes = fields.Integer(default=0)
    replies = fields.List(fields.String())  # Lista de UUIDs de respuestas
    created_at = fields.DateTime(dump_only=True)
    report_count = fields.Integer(default=0)

    @validates('content')
    def validate_content_length(self, content):
        """Validar que el contenido no esté vacío y que su longitud esté entre 1 y 500 caracteres."""
        if not content or len(content) < 1 or len(content) > 500:
            raise ValidationError("El contenido del comentario debe tener entre 1 y 500 caracteres.")

    @validates('user')
    def validate_user_exists(self, user, **kwargs):
        """Valida que el usuario exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.users.find_one({"_id": user}):
            raise ValidationError(f"El usuario con ID {user} no existe.")

    @validates('event')
    def validate_event_exists(self, event, **kwargs):
        """Valida que el evento relacionado exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.events.find_one({"_id": event}):
            raise ValidationError(f"El evento con ID {event} no existe.")

    @validates_schema
    def validate_unique_comment(self, data, **kwargs):
        """Validar que el usuario no comente el mismo evento más de una vez."""
        db = kwargs.get('db_instance')
        user = data['user']
        event = data['event']
        existing_comment = db.comments.find_one({"user": user, "event": event})
        if existing_comment:
            raise ValidationError(f"El usuario con ID {user} ya ha comentado el evento con ID {event}.")
