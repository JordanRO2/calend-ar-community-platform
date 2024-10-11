from bson import ObjectId
from flask import current_app
from core.domain.comment import Comment

class CommentRepository:
    def __init__(self, db):
        self.comments = db.comments  # Colección de comentarios en MongoDB

    def get_by_event_id(self, event_id, page=1, per_page=10):
        """Obtiene comentarios de un evento con paginación opcional."""
        try:
            comment_list = []
            skip = (page - 1) * per_page
            for comment_data in self.comments.find({'event_id': ObjectId(event_id)}).skip(skip).limit(per_page):
                comment_data['id'] = str(comment_data.pop('_id'))  # Convertir ObjectId a string
                comment_list.append(Comment.from_dict(comment_data))
            return comment_list
        except Exception as e:
            current_app.logger.error(f"Error al obtener comentarios para el evento {event_id}: {str(e)}")
            raise Exception(f"Error al obtener los comentarios del evento {event_id}")

    def get_by_user_id(self, user_id, page=1, per_page=10):
        """Obtiene comentarios hechos por un usuario específico con paginación opcional."""
        try:
            comment_list = []
            skip = (page - 1) * per_page
            for comment_data in self.comments.find({'user_id': ObjectId(user_id)}).skip(skip).limit(per_page):
                comment_data['id'] = str(comment_data.pop('_id'))  # Convertir ObjectId a string
                comment_list.append(Comment.from_dict(comment_data))
            return comment_list
        except Exception as e:
            current_app.logger.error(f"Error al obtener comentarios del usuario {user_id}: {str(e)}")
            raise Exception(f"Error al obtener los comentarios del usuario {user_id}")

    def create(self, comment):
        """Crea un nuevo comentario en la base de datos."""
        try:
            comment_dict = comment.to_dict()
            comment_dict['_id'] = ObjectId(comment_dict.pop('id'))  # MongoDB maneja el _id
            self.comments.insert_one(comment_dict)
        except Exception as e:
            current_app.logger.error(f"Error al crear comentario: {str(e)}")
            raise Exception("Error al crear el comentario")

    def delete(self, comment_id):
        """Elimina un comentario por su ID."""
        try:
            result = self.comments.delete_one({'_id': ObjectId(comment_id)})
            if result.deleted_count == 0:
                raise ValueError("Comentario no encontrado")
            current_app.logger.info(f"Comentario con ID {comment_id} eliminado exitosamente.")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar comentario: {str(e)}")
            raise Exception("Error al eliminar el comentario")

    def delete_by_event_id(self, event_id):
        """Elimina todos los comentarios relacionados a un evento específico."""
        try:
            result = self.comments.delete_many({'event_id': ObjectId(event_id)})
            current_app.logger.info(f"Se eliminaron {result.deleted_count} comentarios del evento {event_id}.")
            return result.deleted_count
        except Exception as e:
            current_app.logger.error(f"Error al eliminar comentarios para el evento {event_id}: {str(e)}")
            raise Exception(f"Error al eliminar los comentarios del evento {event_id}")

    def update(self, comment):
        """Actualiza un comentario existente en la base de datos."""
        try:
            comment_dict = comment.to_dict()
            comment_dict['_id'] = ObjectId(comment_dict.pop('id'))  # Convertir 'id' a ObjectId
            result = self.comments.update_one({'_id': ObjectId(comment.id)}, {'$set': comment_dict})
            if result.matched_count == 0:
                raise ValueError("Comentario no encontrado")
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar comentario {comment.id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar comentario {comment.id}: {str(e)}")
            raise Exception("Error al actualizar el comentario")

    # Métodos para manejar 'likes' en comentarios
    def add_like(self, comment_id, user_id):
        """Añade un 'like' a un comentario."""
        try:
            result = self.comments.update_one(
                {'_id': ObjectId(comment_id)},
                {'$addToSet': {'likes': ObjectId(user_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Comentario con ID {comment_id} no encontrado")
            current_app.logger.info(f"Usuario {user_id} dio 'like' al comentario {comment_id}")
        except Exception as e:
            current_app.logger.error(f"Error al añadir 'like' al comentario {comment_id}: {str(e)}")
            raise Exception(f"Error al añadir 'like' al comentario {comment_id}")

    def remove_like(self, comment_id, user_id):
        """Elimina un 'like' de un comentario."""
        try:
            result = self.comments.update_one(
                {'_id': ObjectId(comment_id)},
                {'$pull': {'likes': ObjectId(user_id)}}  # Remover 'like'
            )
            if result.matched_count == 0:
                raise ValueError(f"Comentario con ID {comment_id} no encontrado")
            current_app.logger.info(f"Usuario {user_id} eliminó su 'like' del comentario {comment_id}")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar 'like' del comentario {comment_id}: {str(e)}")
            raise Exception(f"Error al eliminar 'like' del comentario {comment_id}")

    # Métodos para manejar reportes en comentarios
    def add_report(self, comment_id, user_id):
        """Añade un reporte a un comentario."""
        try:
            result = self.comments.update_one(
                {'_id': ObjectId(comment_id)},
                {'$addToSet': {'reports': ObjectId(user_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Comentario con ID {comment_id} no encontrado")
            current_app.logger.info(f"Usuario {user_id} reportó el comentario {comment_id}")
        except Exception as e:
            current_app.logger.error(f"Error al reportar comentario {comment_id}: {str(e)}")
            raise Exception(f"Error al reportar comentario {comment_id}")

    def clear_reports(self, comment_id):
        """Limpia los reportes de un comentario después de una revisión."""
        try:
            result = self.comments.update_one(
                {'_id': ObjectId(comment_id)},
                {'$set': {'reports': []}}  # Vaciar lista de reportes
            )
            if result.matched_count == 0:
                raise ValueError(f"Comentario con ID {comment_id} no encontrado")
            current_app.logger.info(f"Los reportes del comentario {comment_id} han sido eliminados.")
        except Exception as e:
            current_app.logger.error(f"Error al limpiar reportes del comentario {comment_id}: {str(e)}")
            raise Exception(f"Error al limpiar reportes del comentario {comment_id}")
