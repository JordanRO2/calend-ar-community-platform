

import uuid
from datetime import datetime
from marshmallow import Schema, fields, validate, validates, ValidationError

class Community:
    """Clase que representa una comunidad dentro del sistema."""

    def __init__(self, name, description, admin, category, location, type_, image_url=None, moderators=None, members=None, events=None, featured=False):
        self.id = str(uuid.uuid4())
        self.name = name
        self.description = description
        self.admin = admin  
        self.category = category  
        self.location = location  
        self.type = type_  
        self.image_url = image_url  
        self.moderators = moderators if moderators is not None else []
        self.members = members if members is not None else []
        self.events = events if events is not None else []
        self.featured = featured
        self.created_at = datetime.now(datetime.timezone.utc)

class CommunitySchema(Schema):
    """Esquema de validación y serialización de Community utilizando Marshmallow."""

    id = fields.UUID(dump_only=True)
    name = fields.String(required=True, validate=validate.Length(min=1, max=100))
    description = fields.String(required=True, validate=validate.Length(min=1, max=255))
    admin = fields.String(required=True)  
    category = fields.String(required=True, validate=validate.Length(min=1, max=50))  
    location = fields.String(required=True, validate=validate.Length(min=1, max=100))  
    type = fields.String(required=True, validate=validate.OneOf(['Pública', 'Privada']))  
    image_url = fields.String(allow_none=True)  
    moderators = fields.List(fields.String())  
    members = fields.List(fields.String())  
    events = fields.List(fields.String())  
    featured = fields.Boolean(default=False)
    created_at = fields.DateTime(dump_only=True)

    @validates('name')
    def validate_unique_name(self, name, **kwargs):
        """Valida que el nombre de la comunidad sea único."""
        db = kwargs.get('db_instance')
        existing_community = db.communities.find_one({"name": name})
        if existing_community:
            raise ValidationError(f"El nombre '{name}' ya está en uso por otra comunidad.")

    @validates('admin')
    def validate_admin_exists(self, admin, **kwargs):
        """Valida que el administrador de la comunidad exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.users.find_one({"_id": admin}):
            raise ValidationError(f"El usuario con ID {admin} no existe.")

    @validates('moderators')
    def validate_moderators_exist(self, moderators, **kwargs):
        """Valida que todos los moderadores existan en la base de datos."""
        db = kwargs.get('db_instance')
        for moderator in moderators:
            if not db.users.find_one({"_id": moderator}):
                raise ValidationError(f"El moderador con ID {moderator} no existe.")

    @validates('members')
    def validate_members_exist(self, members, **kwargs):
        """Valida que todos los miembros existan en la base de datos."""
        db = kwargs.get('db_instance')
        for member in members:
            if not db.users.find_one({"_id": member}):
                raise ValidationError(f"El miembro con ID {member} no existe.")

    @validates('events')
    def validate_events_exist(self, events, **kwargs):
        """Valida que todos los eventos relacionados existan en la base de datos."""
        db = kwargs.get('db_instance')
        for event in events:
            if not db.events.find_one({"_id": event}):
                raise ValidationError(f"El evento con ID {event} no existe.")
