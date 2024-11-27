import uuid
from datetime import datetime
from marshmallow import Schema, fields, validate, validates, ValidationError

class Event:
    """Clase que representa un evento dentro del sistema."""

    def __init__(self, title, description, community, date_time, location, created_by, image_url=None, attendees=None, comments=None, likes=0, rating=0.0, is_recurring=False, recurrence_pattern=None, recurrence_end=None, featured=False, report_count=0):
        self.id = str(uuid.uuid4())
        self.title = title
        self.description = description
        self.community = community  # UUID de la comunidad
        self.date_time = date_time
        self.location = location
        self.created_by = created_by  # UUID del usuario creador
        self.image_url = image_url  # Nuevo campo para la URL de la imagen
        self.attendees = attendees if attendees is not None else []
        self.comments = comments if comments is not None else []
        self.likes = likes
        self.rating = rating
        self.is_recurring = is_recurring
        self.recurrence_pattern = recurrence_pattern
        self.recurrence_end = recurrence_end
        self.featured = featured
        self.created_at = datetime.utcnow()
        self.report_count = report_count

class EventSchema(Schema):
    """Esquema de validación y serialización de Event utilizando Marshmallow."""
    
    id = fields.UUID(dump_only=True)
    title = fields.String(required=True, validate=validate.Length(min=1, max=150))
    description = fields.String(required=True, validate=validate.Length(min=1, max=500))
    community = fields.String(required=True)  # UUID de la comunidad asociada
    date_time = fields.DateTime(required=True)
    location = fields.String(required=True, validate=validate.Length(min=1, max=255))
    created_by = fields.String(required=True)  # UUID del usuario que creó el evento
    image_url = fields.String(allow_none=True)  # Nuevo campo para la URL de la imagen
    attendees = fields.List(fields.String())  # Lista de UUIDs de los asistentes
    comments = fields.List(fields.String())  # Lista de UUIDs de los comentarios
    likes = fields.Integer(default=0)
    rating = fields.Float(default=0.0, validate=validate.Range(min=0, max=5))
    is_recurring = fields.Boolean(default=False)
    recurrence_pattern = fields.String(allow_none=True)  # Ejemplo: 'weekly', 'monthly'
    recurrence_end = fields.DateTime(allow_none=True)
    featured = fields.Boolean(default=False)
    report_count = fields.Integer(default=0)
    created_at = fields.DateTime(dump_only=True)

    @validates('title')
    def validate_unique_title(self, title, **kwargs):
        """Valida que el título del evento sea único dentro de la misma comunidad."""
        db = kwargs.get('db_instance')
        community_id = kwargs.get('community_id')
        existing_event = db.events.find_one({"title": title, "community": community_id})
        if existing_event:
            raise ValidationError(f"El título '{title}' ya está en uso para otro evento en la misma comunidad.")

    @validates('community')
    def validate_community_exists(self, community, **kwargs):
        """Valida que la comunidad asociada exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.communities.find_one({"_id": community}):
            raise ValidationError(f"La comunidad con ID {community} no existe.")

    @validates('created_by')
    def validate_user_exists(self, created_by, **kwargs):
        """Valida que el usuario que crea el evento exista en la base de datos."""
        db = kwargs.get('db_instance')
        if not db.users.find_one({"_id": created_by}):
            raise ValidationError(f"El usuario con ID {created_by} no existe.")

    @validates('recurrence_end')
    def validate_recurrence_dates(self, recurrence_end, **kwargs):
        """Valida que la fecha de finalización de recurrencia sea posterior a la fecha del evento."""
        date_time = kwargs.get('date_time')
        if recurrence_end and recurrence_end <= date_time:
            raise ValidationError("La fecha de finalización de recurrencia debe ser posterior a la fecha del evento.")
