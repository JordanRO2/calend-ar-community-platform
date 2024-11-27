# relative path: app/domain/notification/entities.py

import uuid
from datetime import datetime
from marshmallow import Schema, fields, validate, validates, ValidationError

class Notification:
    """Clase que representa una notificación dentro del sistema."""

    def __init__(self, user, message, type, status="unread"):
        self.id = str(uuid.uuid4())
        self.user = user  # UUID del usuario destinatario
        self.message = message
        self.type = type  # Tipo de notificación: evento, comentario, recordatorio, etc.
        self.status = status  # Estado de la notificación: leída o no leída
        self.created_at = datetime.utcnow()

class NotificationSchema(Schema):
    """Esquema de validación y serialización de Notification utilizando Marshmallow."""
    
    id = fields.UUID(dump_only=True)
    user = fields.String(required=True)  # UUID del usuario destinatario
    message = fields.String(required=True, validate=validate.Length(min=1, max=255))
    type = fields.String(required=True, validate=validate.OneOf(["evento", "comentario", "recordatorio"]))
    status = fields.String(validate=validate.OneOf(["unread", "read"]), default="unread")
    created_at = fields.DateTime(dump_only=True)

    @validates('user')
    def validate_user_exists(self, user, **kwargs):
        """Valida que el usuario destinatario exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.users.find_one({"_id": user}):
            raise ValidationError(f"El usuario con ID {user} no existe.")
    
    @validates('message')
    def validate_unique_message_for_user(self, message, **kwargs):
        """Valida que el mensaje de notificación no sea un duplicado para el mismo usuario."""
        db = kwargs.get('db_instance')
        user = kwargs.get('user_id')
        existing_notification = db.notifications.find_one({"message": message, "user": user})
        if existing_notification:
            raise ValidationError(f"El mensaje '{message}' ya existe para el usuario con ID {user}.")
