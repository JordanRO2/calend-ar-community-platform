# relative path: app/domain/comment/use_cases.py

from marshmallow import ValidationError
from .repositories import CommentRepository
from .entities import CommentSchema


class CommentUseCases:
    """Clase que define los casos de uso para la entidad Comment."""

    def __init__(self, db):
        self.comment_repository = CommentRepository(db)
        self.comment_schema = CommentSchema()

    def create_comment(self, comment_data):
        """Crea un nuevo comentario."""
        try:
            # Validar los datos del comentario utilizando Marshmallow
            validated_data = self.comment_schema.load(comment_data)
            comment_id = self.comment_repository.create_comment(validated_data)
            return comment_id
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def update_comment(self, user_id, comment_id, new_data):
        """Actualiza el contenido de un comentario, verificando si el usuario es el propietario."""
        try:
            # Obtener los detalles del comentario
            comment = self.comment_repository.get_comment_by_id(comment_id)
            if not comment:
                return {"error": "Comentario no encontrado"}

            # Verificar si el usuario es el propietario del comentario
            if comment['user'] != user_id:
                return {"error": "No tienes permisos para actualizar este comentario"}

            # Validar los nuevos datos del comentario
            validated_data = self.comment_schema.load(new_data, partial=True)
            updated = self.comment_repository.update_comment(comment_id, validated_data)
            if updated:
                return {"message": "Comentario actualizado exitosamente"}
            return {"error": "Error al actualizar el comentario"}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def delete_comment(self, user_id, comment_id):
        """Elimina un comentario, verificando si el usuario es el propietario."""
        try:
            # Obtener los detalles del comentario
            comment = self.comment_repository.get_comment_by_id(comment_id)
            if not comment:
                return {"error": "Comentario no encontrado"}

            # Verificar si el usuario es el propietario del comentario
            if comment['user'] != user_id:
                return {"error": "No tienes permisos para eliminar este comentario"}

            # Proceder a eliminar el comentario
            deleted = self.comment_repository.delete_comment(comment_id)
            if deleted:
                return {"message": "Comentario eliminado exitosamente"}
            return {"error": "Error al eliminar el comentario"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_comment_details(self, comment_id):
        """Obtiene los detalles de un comentario."""
        try:
            comment = self.comment_repository.get_comment_by_id(comment_id)
            if comment:
                return comment
            return {"error": "Comentario no encontrado"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_event_comments(self, event_id, page=1, limit=10):
        """Lista los comentarios de un evento."""
        try:
            comments = self.comment_repository.get_comments_by_event(event_id, page, limit)
            return comments
        except Exception as ex:
            return {"error": str(ex)}

    def like_comment(self, comment_id, user_id):
        """Da like a un comentario."""
        try:
            liked = self.comment_repository.like_comment(comment_id, user_id)
            if liked:
                return {"message": "Like registrado exitosamente"}
            return {"error": "Error al registrar el like"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_comment_likes(self, comment_id):
        """Obtiene la lista de usuarios que dieron like a un comentario."""
        try:
            likes = self.comment_repository.get_comment_likes(comment_id)
            return likes
        except Exception as ex:
            return {"error": str(ex)}

    def report_comment(self, comment_id, report_data):
        """Reporta un comentario inapropiado."""
        try:
            reported = self.comment_repository.report_comment(comment_id, report_data)
            if reported:
                return {"message": "Comentario reportado exitosamente"}
            return {"error": "Error al reportar el comentario"}
        except Exception as ex:
            return {"error": str(ex)}
