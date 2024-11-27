# relative path: app/domain/reply/repositories.py

from bson.objectid import ObjectId

class ReplyRepository:
    """Repositorio responsable de las interacciones con la base de datos para la entidad Reply."""

    def __init__(self, db):
        self.collection = db['replies']

    def create_reply(self, data):
        """Crea una nueva respuesta."""
        # Verificar si el comentario padre existe antes de crear la respuesta
        if not data.get('parent_comment'):
            return {"error": "El comentario padre no existe."}

        result = self.collection.insert_one(data)
        return str(result.inserted_id)

    def update_reply(self, reply_id, data):
        """Actualiza el contenido de una respuesta."""
        # Verificar si la respuesta existe
        if not self.get_reply_by_id(reply_id):
            return {"error": "La respuesta no existe."}

        result = self.collection.update_one({"_id": ObjectId(reply_id)}, {"$set": data})
        return result.modified_count > 0

    def delete_reply(self, reply_id):
        """Elimina una respuesta."""
        # Verificar si la respuesta existe antes de eliminarla
        if not self.get_reply_by_id(reply_id):
            return {"error": "La respuesta no existe."}

        result = self.collection.delete_one({"_id": ObjectId(reply_id)})
        return result.deleted_count > 0

    def get_reply_by_id(self, reply_id):
        """Obtiene una respuesta por su ID."""
        try:
            reply = self.collection.find_one({"_id": ObjectId(reply_id)})
            if reply:
                reply['_id'] = str(reply['_id'])
            return reply
        except Exception:
            return {"error": "Formato de ID no válido."}

    def get_replies_by_comment(self, comment_id, page=1, limit=10):
        """Devuelve una lista paginada de respuestas para un comentario específico."""
        skip = (page - 1) * limit
        replies = self.collection.find({"parent_comment": ObjectId(comment_id)}).skip(skip).limit(limit)
        result = []
        for reply in replies:
            reply['_id'] = str(reply['_id'])
            result.append(reply)
        return result

    def like_reply(self, reply_id, user_id):
        """Registra que un usuario ha dado like a una respuesta."""
        # Verificar si la respuesta existe antes de dar like
        if not self.get_reply_by_id(reply_id):
            return {"error": "La respuesta no existe."}

        result = self.collection.update_one(
            {"_id": ObjectId(reply_id)},
            {"$addToSet": {"likes": user_id}}  # Agregar el user_id a la lista de likes si no está presente
        )
        return result.modified_count > 0

    def get_reply_likes(self, reply_id):
        """Devuelve la lista de usuarios que han dado like a una respuesta."""
        reply = self.collection.find_one({"_id": ObjectId(reply_id)}, {"likes": 1})
        if reply and 'likes' in reply:
            return reply['likes']
        return []
