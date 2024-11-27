# relative path: app/domain/calendar/entities.py

import uuid
from datetime import datetime
from marshmallow import Schema, fields, validate, validates, ValidationError

class Calendar:
    """Clase que representa un calendario dentro del sistema."""

    def __init__(self, name, owner, events=None, is_public=True, shared_url=None):
        self.id = str(uuid.uuid4())
        self.name = name
        self.owner = owner  # Puede ser un UUID de usuario o de comunidad
        self.events = events if events is not None else []
        self.is_public = is_public
        self.shared_url = shared_url if shared_url is not None else f"/calendars/{self.id}/share"
        self.created_at = datetime.utcnow()

class CalendarSchema(Schema):
    """Esquema de validación y serialización de Calendar utilizando Marshmallow."""
    
    id = fields.UUID(dump_only=True)
    name = fields.String(required=True, validate=validate.Length(min=1, max=100))
    owner = fields.String(required=True)  # UUID del propietario, puede ser un usuario o comunidad
    events = fields.List(fields.String())  # Lista de UUIDs de los eventos
    is_public = fields.Boolean(default=True)
    shared_url = fields.Url(dump_only=True)  # URL pública generada
    created_at = fields.DateTime(dump_only=True)

    @validates('name')
    def validate_unique_name(self, name, **kwargs):
        """
        Valida que no exista ya un calendario con el mismo nombre para el mismo propietario (owner).
        Se debe usar un repositorio para verificar la existencia de un nombre duplicado.
        """
        db = kwargs.get('db_instance')  # Obtener instancia de base de datos
        owner = kwargs.get('owner')  # El propietario se pasa como parámetro
        existing_calendar = db.calendars.find_one({"name": name, "owner": owner})
        if existing_calendar:
            raise ValidationError(f"Ya existe un calendario con el nombre '{name}' para este propietario.")

