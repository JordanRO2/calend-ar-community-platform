import uuid
from datetime import datetime, timezone
from marshmallow import Schema, fields, validate

class User:
    """Clase que representa a un usuario dentro del sistema."""

    def __init__(self, name, email, password, role="member", communities=None, events_attended=None, notifications=None, is_active=True, profile_image=None):
        self.id = str(uuid.uuid4())
        self.name = name
        self.email = email
        self.password = password
        self.role = role
        self.communities = communities if communities is not None else []
        self.events_attended = events_attended if events_attended is not None else []
        self.notifications = notifications if notifications is not None else []
        self.is_active = is_active
        self.created_at = datetime.now(timezone.utc)
        self.profile_image = profile_image  

class UserSchema(Schema):
    """Esquema de validación y serialización de User utilizando Marshmallow."""
    
    id = fields.UUID(dump_only=True)
    name = fields.String(required=True, validate=validate.Length(min=1, max=100))
    email = fields.Email(required=True)
    password = fields.String(required=True, load_only=True)
    role = fields.String(validate=validate.OneOf(["admin", "moderator", "member"]))
    communities = fields.List(fields.String())  
    events_attended = fields.List(fields.String())  
    notifications = fields.List(fields.String())  
    is_active = fields.Boolean(default=True)
    created_at = fields.DateTime(dump_only=True)
    profile_image = fields.String(validate=validate.URL())  # Validación para URL
