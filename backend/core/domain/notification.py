from bson import ObjectId
from datetime import datetime, timezone

class NotificationStatus:
    """Clase para manejar estados de la notificación."""
    UNREAD = "unread"
    READ = "read"

    @staticmethod
    def is_valid(status):
        return status in {NotificationStatus.UNREAD, NotificationStatus.READ}

class Notification:
    def __init__(self, id=None, user_id=None, message=None, status=None, created_at=None, event_id=None):
        # Validaciones
        if not message or len(message) > 200:
            raise ValueError("El mensaje de la notificación es obligatorio y debe tener menos de 200 caracteres.")
        if not NotificationStatus.is_valid(status):
            raise ValueError("Estado de notificación inválido. Debe ser 'unread' o 'read'.")
        if not user_id:
            raise ValueError("El ID de usuario es obligatorio.")

        self.id = ObjectId() if id is None else ObjectId(id)
        self.user_id = ObjectId(user_id)
        self.event_id = ObjectId(event_id) if event_id else None
        self.message = message
        self.status = status or NotificationStatus.UNREAD
        self.created_at = created_at or datetime.now(timezone.utc)

    def to_dict(self):
        """Convierte el objeto Notification a un diccionario."""
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'event_id': str(self.event_id) if self.event_id else None,
            'message': self.message,
            'status': self.status,
            'created_at': self.created_at.isoformat(),
        }

    @staticmethod
    def from_dict(data):
        """Crea una instancia de Notification a partir de un diccionario."""
        id = data.get('id')
        user_id = data.get('user_id')
        message = data.get('message')
        status = data.get('status')
        created_at_str = data.get('created_at')
        event_id = data.get('event_id')

        if not message or not status or not user_id or not created_at_str:
            raise ValueError("Faltan campos obligatorios en el JSON de notificación.")

        created_at = datetime.fromisoformat(created_at_str)

        if not NotificationStatus.is_valid(status):
            raise ValueError("Estado de notificación inválido.")

        return Notification(
            id=id,
            user_id=user_id,
            event_id=event_id,
            message=message,
            status=status,
            created_at=created_at
        )

    def mark_as_read(self):
        """Marca la notificación como leída."""
        if self.status == NotificationStatus.READ:
            raise ValueError("La notificación ya ha sido marcada como leída.")
        self.status = NotificationStatus.READ

    def mark_as_unread(self):
        """Marca la notificación como no leída."""
        if self.status == NotificationStatus.UNREAD:
            raise ValueError("La notificación ya está marcada como no leída.")
        self.status = NotificationStatus.UNREAD
