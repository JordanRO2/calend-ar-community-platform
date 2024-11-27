# relative path: app/domain/reply/use_cases.py

from marshmallow import ValidationError
from .repositories import ReplyRepository
from .entities import ReplySchema

class ReplyUseCases:
    """Clase que define los casos de uso para la entidad Reply."""

    def __init__(self, db):
        self.reply_repository = ReplyRepository(db)
        self.reply_schema = ReplySchema()

    def create_reply(self, reply_data):
        """Crea una nueva respuesta."""
        try:
            # Validar los datos de la respuesta utilizando Marshmallow
            validated_data = self.reply_schema.load(reply_data)
            reply_id = self.reply_repository.create_reply(validated_data)
            return {"message": "Respuesta creada exitosamente", "reply_id": reply_id}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def update_reply(self, reply_id, new_data):
        """Actualiza el contenido de una respuesta."""
        try:
            # Validar los nuevos datos de la respuesta
            validated_data = self.reply_schema.load(new_data, partial=True)
            updated = self.reply_repository.update_reply(reply_id, validated_data)
            if updated:
                return {"message": "Respuesta actualizada exitosamente"}
            return {"error": "Error al actualizar la respuesta"}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def delete_reply(self, reply_id):
        """Elimina una respuesta."""
        try:
            deleted = self.reply_repository.delete_reply(reply_id)
            if deleted:
                return {"message": "Respuesta eliminada exitosamente"}
            return {"error": "Error al eliminar la respuesta"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_reply_details(self, reply_id):
        """Obtiene los detalles de una respuesta."""
        try:
            reply = self.reply_repository.get_reply_by_id(reply_id)
            if reply:
                return reply
            return {"error": "Respuesta no encontrada"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_comment_replies(self, comment_id, page=1, limit=10):
        """Lista las respuestas de un comentario."""
        try:
            return self.reply_repository.get_replies_by_comment(comment_id, page, limit)
        except Exception as ex:
            return {"error": str(ex)}

    def like_reply(self, reply_id, user_id):
        """Da like a una respuesta."""
        try:
            liked = self.reply_repository.like_reply(reply_id, user_id)
            if liked:
                return {"message": "Like registrado exitosamente"}
            return {"error": "Error al registrar el like"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_reply_likes(self, reply_id):
        """Obtiene la lista de usuarios que dieron like a una respuesta."""
        try:
            return self.reply_repository.get_reply_likes(reply_id)
        except Exception as ex:
            return {"error": str(ex)}
