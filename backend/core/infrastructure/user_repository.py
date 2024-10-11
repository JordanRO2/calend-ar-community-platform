from bson import ObjectId
from flask import current_app
from core.domain.user import User

class UserRepository:
    def __init__(self, db):
        self.users = db.users  # Colección de usuarios en MongoDB

    # Crear un nuevo usuario
    def create(self, user):
        try:
            user_dict = user.to_dict()
            user_dict['_id'] = ObjectId()  # Generar un nuevo _id para MongoDB
            self.users.insert_one(user_dict)
            current_app.logger.info(f"Usuario {user.username} creado exitosamente")
        except Exception as e:
            current_app.logger.error(f"Error al crear usuario: {str(e)}")
            raise Exception("Error al crear usuario")

    # Obtener todos los usuarios
    def get_all(self):
        try:
            users = []
            for user_data in self.users.find():
                user_data['id'] = str(user_data.pop('_id'))  # Convertir ObjectId a string
                users.append(User(**user_data))  # Crear la entidad User
            return users
        except Exception as e:
            current_app.logger.error(f"Error al obtener usuarios: {str(e)}")
            raise Exception("Error al obtener usuarios")

    # Obtener un usuario por ID
    def get_by_id(self, user_id):
        try:
            user_data = self.users.find_one({'_id': ObjectId(user_id)})
            if user_data:
                user_data['id'] = str(user_data.pop('_id'))  # Convertir ObjectId a string
                return User(**user_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener usuario por ID {user_id}: {str(e)}")
            raise Exception("Error al obtener usuario por ID")

    # Obtener un usuario por nombre de usuario
    def get_by_username(self, username):
        try:
            user_data = self.users.find_one({'username': username})
            if user_data:
                user_data['id'] = str(user_data.pop('_id'))  # Convertir ObjectId a string
                return User(**user_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener usuario por nombre de usuario {username}: {str(e)}")
            raise Exception("Error al obtener usuario por nombre de usuario")

    # Obtener un usuario por correo electrónico
    def get_by_email(self, email):
        try:
            user_data = self.users.find_one({'email': email})
            if user_data:
                user_data['id'] = str(user_data.pop('_id'))  # Convertir ObjectId a string
                return User(**user_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener usuario por correo {email}: {str(e)}")
            raise Exception("Error al obtener usuario por correo")

    # Actualizar un usuario
    def update(self, user):
        try:
            user_dict = user.to_dict()
            user_dict['_id'] = ObjectId(user_dict.pop('id'))  # Convertir 'id' a ObjectId
            result = self.users.update_one({'_id': user_dict['_id']}, {'$set': user_dict})
            if result.matched_count == 0:
                raise ValueError("Usuario no encontrado")
            current_app.logger.info(f"Usuario {user.username} actualizado exitosamente")
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar usuario {user.id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar usuario {user.id}: {str(e)}")
            raise Exception("Error al actualizar usuario")

    # Eliminar un usuario
    def delete(self, user_id):
        try:
            result = self.users.delete_one({'_id': ObjectId(user_id)})
            if result.deleted_count == 0:
                raise ValueError("Usuario no encontrado")
            current_app.logger.info(f"Usuario con ID {user_id} eliminado exitosamente")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar usuario {user_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar usuario {user_id}: {str(e)}")
            raise Exception("Error al eliminar usuario")

    # Añadir una comunidad a un usuario
    def add_community(self, user_id, community_id):
        try:
            result = self.users.update_one(
                {'_id': ObjectId(user_id)},
                {'$addToSet': {'community_ids': ObjectId(community_id)}}  # Evita duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Usuario con ID {user_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al añadir comunidad al usuario {user_id}: {str(e)}")
            raise Exception(f"Error al añadir comunidad al usuario {user_id}")

    # Eliminar una comunidad de un usuario
    def remove_community(self, user_id, community_id):
        try:
            result = self.users.update_one(
                {'_id': ObjectId(user_id)},
                {'$pull': {'community_ids': ObjectId(community_id)}}  # Eliminar la comunidad
            )
            if result.matched_count == 0:
                raise ValueError(f"Usuario con ID {user_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar comunidad del usuario {user_id}: {str(e)}")
            raise Exception(f"Error al eliminar comunidad del usuario {user_id}")

    # Añadir una notificación a un usuario
    def add_notification(self, user_id, notification_id):
        try:
            result = self.users.update_one(
                {'_id': ObjectId(user_id)},
                {'$addToSet': {'notifications': ObjectId(notification_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Usuario con ID {user_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al añadir notificación al usuario {user_id}: {str(e)}")
            raise Exception(f"Error al añadir notificación al usuario {user_id}")

    # Limpiar notificaciones de un usuario
    def clear_notifications(self, user_id):
        try:
            result = self.users.update_one(
                {'_id': ObjectId(user_id)},
                {'$set': {'notifications': []}}  # Vaciar la lista de notificaciones
            )
            if result.matched_count == 0:
                raise ValueError(f"Usuario con ID {user_id} no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al limpiar notificaciones del usuario {user_id}: {str(e)}")
            raise Exception(f"Error al limpiar notificaciones del usuario {user_id}")
