# relative path: app/domain/comment/repositories.py

from pymongo import MongoClient
from bson.objectid import ObjectId

class CommentRepository:
    """Repositorio que maneja todas las operaciones CRUD relacionadas con los comentarios."""

    def __init__(self, db: MongoClient):
        self.comments = db.comments  # Colección de comentarios en MongoDB

    def create_comment(self, data):
        """Crea un nuevo comentario en la base de datos."""
        # Validar que no haya comentarios duplicados con el mismo contenido del mismo usuario para el mismo evento
        existing_comment = self.comments.find_one({'user': data['user'], 'event': data['event'], 'content': data['content']})
        if existing_comment:
            return {"error": "Ya existe un comentario con el mismo contenido para este usuario y evento."}

        result = self.comments.insert_one(data)
        return str(result.inserted_id)

    def update_comment(self, comment_id, data):
        """Actualiza el contenido de un comentario si existe."""
        # Verificar si el comentario existe
        existing_comment = self.get_comment_by_id(comment_id)
        if not existing_comment:
            return {"error": "El comentario no existe."}

        result = self.comments.update_one({'_id': ObjectId(comment_id)}, {'$set': data})
        return result.modified_count > 0

    def delete_comment(self, comment_id):
        """Elimina un comentario de la base de datos si existe."""
        # Verificar si el comentario existe
        existing_comment = self.get_comment_by_id(comment_id)
        if not existing_comment:
            return {"error": "El comentario no existe."}

        result = self.comments.delete_one({'_id': ObjectId(comment_id)})
        return result.deleted_count > 0

    def get_comment_by_id(self, comment_id):
        """Obtiene un comentario por su ID."""
        try:
            comment = self.comments.find_one({'_id': ObjectId(comment_id)})
            if comment:
                comment['_id'] = str(comment['_id'])
            return comment
        except Exception:
            return {"error": "Formato de ID no válido."}

    def get_comments_by_event(self, event_id, page=1, limit=10):
        """Obtiene una lista paginada de comentarios para un evento."""
        skip = (page - 1) * limit
        comments = self.comments.find({'event': event_id}).skip(skip).limit(limit)
        return [{'_id': str(comment['_id']), **comment} for comment in comments]

    def like_comment(self, comment_id, user_id):
        """Da like a un comentario si no ha sido ya dado por el mismo usuario."""
        # Verificar si el comentario existe
        existing_comment = self.get_comment_by_id(comment_id)
        if not existing_comment:
            return {"error": "El comentario no existe."}

        # Verificar si el usuario ya ha dado like
        if user_id in existing_comment.get('likes', []):
            return {"error": "El usuario ya ha dado like a este comentario."}

        # Agregar el like
        result = self.comments.update_one(
            {'_id': ObjectId(comment_id)},
            {'$addToSet': {'likes': user_id}}
        )
        return result.modified_count > 0

    def get_comment_likes(self, comment_id):
        """Devuelve la lista de usuarios que dieron like a un comentario."""
        comment = self.get_comment_by_id(comment_id)
        return comment.get('likes', []) if comment else {"error": "El comentario no existe."}

    def report_comment(self, comment_id, report_data):
        """Reporta un comentario inapropiado si no ha sido ya reportado por el mismo usuario."""
        # Verificar si el comentario existe
        existing_comment = self.get_comment_by_id(comment_id)
        if not existing_comment:
            return {"error": "El comentario no existe."}

        # Verificar si el comentario ya fue reportado con el mismo detalle
        if existing_comment.get('report_data') == report_data:
            return {"error": "Este comentario ya fue reportado con el mismo detalle."}

        # Reportar el comentario y aumentar el contador de reportes
        result = self.comments.update_one(
            {'_id': ObjectId(comment_id)},
            {'$set': {'report_data': report_data}, '$inc': {'report_count': 1}}
        )
        return result.modified_count > 0

    def get_reported_comments(self, page=1, limit=10):
        """Devuelve una lista paginada de comentarios reportados."""
        skip = (page - 1) * limit
        reported_comments = self.comments.find({'report_count': {'$gt': 0}}).skip(skip).limit(limit)
        return [{'_id': str(comment['_id']), **comment} for comment in reported_comments]
