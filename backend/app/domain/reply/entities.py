# relative path: app/domain/reply/entities.py

import uuid
from datetime import datetime
from marshmallow import Schema, fields, validate, validates, ValidationError

class Reply:
    """Clase que representa una respuesta a un comentario dentro del sistema."""

    def __init__(self, user, parent_comment, content, likes=0):
        self.id = str(uuid.uuid4())
        self.user = user  # UUID del usuario que hizo la respuesta
        self.parent_comment = parent_comment  # UUID del comentario al que responde
        self.content = content
        self.likes = likes
        self.created_at = datetime.now(datetime.timezone.utc)

class ReplySchema(Schema):
    """Esquema de validación y serialización de Reply utilizando Marshmallow."""
    
    id = fields.UUID(dump_only=True)
    user = fields.String(required=True)  # UUID del usuario
    parent_comment = fields.String(required=True)  # UUID del comentario padre
    content = fields.String(required=True, validate=validate.Length(min=1, max=500))
    likes = fields.Integer(default=0)
    created_at = fields.DateTime(dump_only=True)

    @validates('user')
    def validate_user_exists(self, user, **kwargs):
        """Valida que el usuario que responde exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.users.find_one({"_id": user}):
            raise ValidationError(f"El usuario con ID {user} no existe.")
    
    @validates('parent_comment')
    def validate_parent_comment_exists(self, parent_comment, **kwargs):
        """Valida que el comentario al que se responde exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.comments.find_one({"_id": parent_comment}):
            raise ValidationError(f"El comentario padre con ID {parent_comment} no existe.")
