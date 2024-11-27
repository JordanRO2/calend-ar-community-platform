from werkzeug.security import check_password_hash, generate_password_hash
from flask_jwt_extended import create_access_token, create_refresh_token, get_jwt_identity
from datetime import timedelta
from .repositories import UserRepository


class UserUseCases:
    def __init__(self, db):
        self.user_repository = UserRepository(db)

    def register_user(self, user_data):
        """Registra un nuevo usuario."""
        try:
            # Validar la contraseña en el backend:
            if 'password' not in user_data:
                print("Error: Contraseña faltante en user_data.")
                return {"error": "Contraseña requerida"}, 400

            if len(user_data['password']) < 8:
                print("Error: La contraseña debe tener al menos 8 caracteres.")
                return {"error": "La contraseña debe tener al menos 8 caracteres"}, 400

            user_id = self.user_repository.create_user(user_data)

            if "error" in user_id:  # El repositorio devuelve un error
                print(f"Error del repositorio al crear usuario: {user_id['error']}")
                return user_id, 400  # Propaga el error y el código 400

            tokens = self._generate_jwt_tokens(user_id)
            tokens['user_id'] = user_id  # Añadir el user_id al resultado
            return tokens, 201

        except Exception as ex:
            print(f"Error inesperado en register_user: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def login_user(self, email, password):
        """Inicia sesión con las credenciales del usuario."""
        print(f"-> Inicio de login_user. Email: {email}")
        try:
            print(f"Buscando usuario con email: {email}")
            user = self.user_repository.get_user_by_email(email)
            print(f"Usuario encontrado: {user}")

            if not user:
                print("Error: Usuario no encontrado")
                return {"error": "Credenciales incorrectas"}, 401

            if "password" not in user:
                print("Error: El usuario no tiene una contraseña establecida.")
                return {"error": "Credenciales incorrectas"}, 401

            if not check_password_hash(user["password"], password):
                print("Error: Contraseña incorrecta.")
                return {"error": "Credenciales incorrectas"}, 401

            print("Usuario autenticado correctamente.")
            user_id = user["_id"]
            tokens = self._generate_jwt_tokens(user_id)
            tokens['user_id'] = user_id  # Añadir el user_id al resultado
            print(f"Tokens generados: {tokens}")

            return tokens, 200  # Devuelve los tokens y el user_id

        except Exception as ex:
            print(f"Error inesperado en login_user: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def reset_password(self, email):
        """Inicia el proceso de reseteo de contraseña para un usuario."""
        try:
            user = self.user_repository.get_user_by_email(email)
            if not user:
                return {"error": "Usuario no encontrado"}, 404

            # Aquí deberías implementar la lógica para enviar un correo electrónico con el enlace de restablecimiento
            # Por ahora, simplemente devolvemos un mensaje indicando que el proceso se ha iniciado
            return {"message": "Se ha enviado un correo electrónico para restablecer la contraseña"}, 200

        except Exception as ex:
            print(f"Error en reset_password: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def update_password(self, user_id, new_password):
        """Actualiza la contraseña de un usuario."""
        try:
            result = self.user_repository.reset_password(user_id, new_password)
            if "error" in result:
                return result, 400
            return {"message": "Contraseña actualizada con éxito"}, 200

        except Exception as ex:
            print(f"Error en update_password: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def update_user(self, user_id, user_data):
        """Actualiza los datos del usuario."""
        try:
            result = self.user_repository.update_user(user_id, user_data)
            if not result:
                return {"error": "No se pudo actualizar el usuario"}, 400
            return {"message": "Usuario actualizado con éxito"}, 200

        except Exception as ex:
            print(f"Error en update_user: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def delete_user(self, user_id):
        """Elimina un usuario."""
        try:
            result = self.user_repository.delete_user(user_id)
            if not result:
                return {"error": "No se pudo eliminar el usuario"}, 400
            return {"message": "Usuario eliminado con éxito"}, 200

        except Exception as ex:
            print(f"Error en delete_user: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def get_user_by_id(self, user_id):
        """Obtiene un usuario por su ID."""
        try:
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                return {"error": "Usuario no encontrado"}, 404
            return user, 200

        except Exception as ex:
            print(f"Error en get_user_by_id: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def get_all_users(self, page=1, limit=10):
        """Obtiene todos los usuarios de forma paginada."""
        try:
            users = self.user_repository.get_all_users(page, limit)
            return users, 200

        except Exception as ex:
            print(f"Error en get_all_users: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def refresh_token(self):
        """Refresca el token de acceso."""
        try:
            current_user = get_jwt_identity()
            new_access_token = create_access_token(identity=current_user, expires_delta=timedelta(hours=1))
            return {"access_token": new_access_token}, 200
        except Exception as ex:
            print(f"Error en refresh_token: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def disable_user(self, user_id):
        """Deshabilita un usuario."""
        try:
            result = self.user_repository.disable_user(user_id)
            if not result:
                return {"error": "No se pudo deshabilitar el usuario"}, 400
            return {"message": "Usuario deshabilitado con éxito"}, 200

        except Exception as ex:
            print(f"Error en disable_user: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def get_users_by_community(self, community_id, page=1, limit=10):
        """Obtiene usuarios por comunidad de forma paginada."""
        try:
            users = self.user_repository.get_users_by_community(community_id, page, limit)
            if not users:
                return {"error": "No se encontraron usuarios para esta comunidad"}, 404
            return users, 200

        except Exception as ex:
            print(f"Error en get_users_by_community: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def get_user_profile(self, user_id):
        """Obtiene el perfil del usuario."""
        try:
            user = self.user_repository.get_user_by_id(user_id)
            if not user:
                return None
            # Excluir la contraseña del perfil
            user.pop('password', None)
            return user
        except Exception as ex:
            print(f"Error en get_user_profile: {str(ex)}")
            return None

    def update_user_profile(self, user_id, new_data):
        """Actualiza el perfil del usuario."""
        try:
            # No permitir la actualización de campos sensibles directamente
            sensitive_fields = ['password', 'email', 'role', 'is_active']
            for field in sensitive_fields:
                new_data.pop(field, None)

            result = self.user_repository.update_user(user_id, new_data)
            if not result:
                return {"error": "No se pudo actualizar el perfil"}, 400
            return {"message": "Perfil actualizado con éxito"}, 200

        except Exception as ex:
            print(f"Error en update_user_profile: {str(ex)}")
            return {"error": "Error interno del servidor"}, 500

    def disable_user_account(self, user_id):
        """Deshabilita la cuenta del usuario."""
        try:
            result = self.user_repository.disable_user(user_id)
            if not result:
                return False
            return True
        except Exception as ex:
            print(f"Error en disable_user_account: {str(ex)}")
            return False

    def _generate_jwt_tokens(self, user_id):
        """Genera tokens JWT de acceso y refresco."""
        try:
            access_token = create_access_token(identity=user_id, expires_delta=timedelta(hours=1))
            refresh_token = create_refresh_token(identity=user_id, expires_delta=timedelta(days=30))
            return {"access_token": access_token, "refresh_token": refresh_token}
        except Exception as ex:
            print(f"Error al generar tokens JWT: {str(ex)}")
            return {"error": "Error al generar tokens"}
