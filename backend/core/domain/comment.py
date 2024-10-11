from bson import ObjectId
from datetime import datetime, timezone

class CommentText:
    def __init__(self, value):
        # Validación de longitud y contenido del comentario
        if not value or len(value.strip()) == 0:
            raise ValueError("El texto del comentario no puede estar vacío.")
        if len(value) > 280:
            raise ValueError("El texto del comentario excede los 280 caracteres.")
        self.value = value.strip()

    def to_dict(self):
        return {'value': self.value}

    @staticmethod
    def from_dict(data):
        value = data.get('value')
        if not value:
            raise ValueError("Falta el campo 'value' en el comentario.")
        return CommentText(value)

class Comment:
    def __init__(self, id=None, event_id=None, user_id=None, text=None, parent_comment_id=None, created_at=None, updated_at=None):
        # Validación de campos obligatorios
        if not event_id or not user_id or not text:
            raise ValueError("Faltan campos obligatorios para crear el comentario.")

        self.id = ObjectId() if id is None else ObjectId(id)
        self.event_id = ObjectId(event_id)  # ID del evento al que pertenece el comentario
        self.user_id = ObjectId(user_id)    # ID del usuario que hizo el comentario
        self.text = text if isinstance(text, CommentText) else CommentText(text)
        self.parent_comment_id = ObjectId(parent_comment_id) if parent_comment_id else None  # ID del comentario al que responde (si es una respuesta)
        self.created_at = created_at or datetime.now(timezone.utc)
        self.updated_at = updated_at or datetime.now(timezone.utc)
        self.likes = []  # Lista de IDs de usuarios que han dado 'like' al comentario
        self.reports = []  # Lista de IDs de usuarios que han reportado el comentario

    def to_dict(self):
        """Convierte el objeto Comment a un diccionario."""
        return {
            'id': str(self.id),
            'event_id': str(self.event_id),
            'user_id': str(self.user_id),
            'text': self.text.to_dict(),
            'parent_comment_id': str(self.parent_comment_id) if self.parent_comment_id else None,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
            'likes': [str(user_id) for user_id in self.likes],
            'reports': [str(user_id) for user_id in self.reports],
        }

    @staticmethod
    def from_dict(data):
        """Crea una instancia de Comment a partir de un diccionario."""
        id = data.get('id')
        event_id = data.get('event_id')
        user_id = data.get('user_id')
        text_data = data.get('text')
        parent_comment_id = data.get('parent_comment_id')
        created_at_str = data.get('created_at')
        updated_at_str = data.get('updated_at')
        likes = data.get('likes', [])
        reports = data.get('reports', [])

        if not event_id or not user_id or not text_data:
            raise ValueError("Faltan campos obligatorios en el comentario.")

        # Convertir fechas de string a datetime
        created_at = datetime.fromisoformat(created_at_str) if created_at_str else datetime.now(timezone.utc)
        updated_at = datetime.fromisoformat(updated_at_str) if updated_at_str else datetime.now(timezone.utc)

        text = CommentText.from_dict(text_data)

        return Comment(
            id=id,
            event_id=event_id,
            user_id=user_id,
            text=text,
            parent_comment_id=parent_comment_id,
            created_at=created_at,
            updated_at=updated_at,
            likes=[ObjectId(uid) for uid in likes],
            reports=[ObjectId(uid) for uid in reports]
        )

    def update(self, new_text):
        """Actualiza el texto y la marca de tiempo de un comentario."""
        self.text = CommentText(new_text)
        self.updated_at = datetime.now(timezone.utc)

    def add_like(self, user_id):
        """Añade un 'like' al comentario por parte de un usuario."""
        user_id = ObjectId(user_id)
        if user_id not in self.likes:
            self.likes.append(user_id)

    def remove_like(self, user_id):
        """Elimina un 'like' del comentario por parte de un usuario."""
        user_id = ObjectId(user_id)
        if user_id in self.likes:
            self.likes.remove(user_id)

    def add_report(self, user_id):
        """Añade un reporte al comentario por parte de un usuario."""
        user_id = ObjectId(user_id)
        if user_id not in self.reports:
            self.reports.append(user_id)

    def clear_reports(self):
        """Limpia todos los reportes del comentario (por ejemplo, después de una revisión)."""
        self.reports = []
