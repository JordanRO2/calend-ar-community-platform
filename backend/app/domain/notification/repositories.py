# relative path: app/domain/notification/repositories.py

from pymongo import MongoClient
from bson.objectid import ObjectId

class NotificationRepository:
    """Repositorio que maneja todas las operaciones CRUD relacionadas con las notificaciones."""

    def __init__(self, db: MongoClient):
        self.notifications = db.notifications  # Colección de notificaciones en MongoDB

    def create_notification(self, data):
        """Crea una nueva notificación en la base de datos."""
        # Validar si la notificación ya existe (basada en el usuario y el mensaje)
        existing_notification = self.notifications.find_one({
            'user': data['user'],
            'message': data['message']
        })
        if existing_notification:
            return {"error": "Ya existe una notificación similar para este usuario."}

        result = self.notifications.insert_one(data)
        return str(result.inserted_id)

    def mark_as_read(self, notification_id):
        """Marca una notificación como leída actualizando el campo status."""
        # Verificar si la notificación existe
        if not self.get_notification_by_id(notification_id):
            return {"error": "La notificación no existe."}

        result = self.notifications.update_one(
            {'_id': ObjectId(notification_id)},
            {'$set': {'status': 'read'}}
        )
        return result.modified_count > 0

    def get_notification_by_id(self, notification_id):
        """Obtiene una notificación por su ID."""
        try:
            notification = self.notifications.find_one({'_id': ObjectId(notification_id)})
            if notification:
                notification['_id'] = str(notification['_id'])
            return notification
        except Exception:
            return {"error": "Formato de ID no válido."}

    def get_notifications_by_user(self, user_id, page=1, limit=10):
        """Obtiene una lista paginada de notificaciones de un usuario."""
        skip = (page - 1) * limit
        notifications = self.notifications.find({'user': user_id}).skip(skip).limit(limit)
        return [{'_id': str(notification['_id']), **notification} for notification in notifications]

    def delete_notification(self, notification_id):
        """Elimina una notificación de la base de datos."""
        # Verificar si la notificación existe
        if not self.get_notification_by_id(notification_id):
            return {"error": "La notificación no existe."}

        result = self.notifications.delete_one({'_id': ObjectId(notification_id)})
        return result.deleted_count > 0
