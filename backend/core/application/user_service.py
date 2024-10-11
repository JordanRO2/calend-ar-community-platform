from flask import current_app
from core.domain.user import User

class UserService:
    def __init__(self, user_repository):
        self.user_repository = user_repository

    def create_user(self, username, password_hash, email):
        """Crea un nuevo usuario si el nombre de usuario y correo electrónico no están en uso."""
        try:
            current_app.logger.info(f"Intentando crear usuario: {username}, {email}")

            # Verificar que el nombre de usuario y correo no estén en uso
            if self.get_user_by_username(username):
                raise ValueError("El nombre de usuario ya está en uso")

            if self.get_user_by_email(email):
                raise ValueError("El correo electrónico ya está en uso")

            # Crear el nuevo usuario
            user = User(username=username, email=email, password_hash=password_hash)
            self.user_repository.create(user)
            current_app.logger.info("Usuario creado exitosamente")
            return user
        except Exception as e:
            current_app.logger.error(f"Error al crear usuario: {str(e)}")
            raise Exception("Error al crear el usuario")

    def authenticate_user(self, username, hashed_password):
        """Autentica a un usuario verificando el nombre de usuario y contraseña."""
        try:
            current_app.logger.info(f"Autenticando usuario: {username}")

            user = self.user_repository.get_by_username(username)

            if user is None:
                current_app.logger.error(f"Usuario no encontrado: {username}")
                return None

            if user.check_password(hashed_password):
                current_app.logger.info(f"Usuario autenticado: {username}")
                return user
            else:
                current_app.logger.error("Contraseña incorrecta")
                return None
        except Exception as e:
            current_app.logger.error(f"Error en la autenticación del usuario: {str(e)}")
            raise Exception("Error en la autenticación del usuario")

    def get_all_users(self):
        """Obtiene todos los usuarios del sistema."""
        try:
            users = self.user_repository.get_all()
            return users
        except Exception as e:
            current_app.logger.error(f"Error al obtener todos los usuarios: {str(e)}")
            raise Exception("Error al obtener los usuarios")

    def get_user_by_id(self, user_id):
        """Obtiene un usuario por su ID."""
        try:
            user = self.user_repository.get_by_id(user_id)
            if user:
                return user
            else:
                current_app.logger.error(f"Usuario no encontrado con ID: {user_id}")
                return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener usuario por ID: {str(e)}")
            raise Exception("Error al obtener el usuario")

    def get_user_by_username(self, username):
        """Obtiene un usuario por su nombre de usuario."""
        try:
            user = self.user_repository.get_by_username(username)
            if user:
                return user
            else:
                return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener usuario por nombre de usuario: {str(e)}")
            raise Exception("Error al obtener el usuario por nombre de usuario")

    def get_user_by_email(self, email):
        """Obtiene un usuario por su correo electrónico."""
        try:
            user = self.user_repository.get_by_email(email)
            if user:
                return user
            else:
                return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener usuario por correo: {str(e)}")
            raise Exception("Error al obtener el usuario por correo electrónico")

    def update_user(self, user_id, user_data):
        """Actualiza la información de un usuario existente."""
        try:
            user = self.get_user_by_id(user_id)
            if user:
                user.update(user_data)
                self.user_repository.update(user)
                current_app.logger.info(f"Usuario actualizado: {user_id}")
                return user
            else:
                current_app.logger.error(f"Usuario no encontrado con ID: {user_id}")
                return None
        except Exception as e:
            current_app.logger.error(f"Error al actualizar usuario: {str(e)}")
            raise Exception("Error al actualizar el usuario")

    def delete_user(self, user_id):
        """Elimina un usuario del sistema."""
        try:
            user = self.get_user_by_id(user_id)
            if user:
                self.user_repository.delete(user_id)
                current_app.logger.info(f"Usuario eliminado con éxito: {user_id}")
            else:
                current_app.logger.error(f"Usuario no encontrado con ID: {user_id}")
                raise ValueError("Usuario no encontrado")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar usuario: {str(e)}")
            raise Exception("Error al eliminar el usuario")

    def is_site_admin(self, user_id):
        """Verifica si un usuario es administrador del sitio."""
        user = self.get_user_by_id(user_id)
        return user and user.is_admin
