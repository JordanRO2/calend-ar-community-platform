from werkzeug.security import generate_password_hash
from bson.objectid import ObjectId

class UserRepository:
    """Repositorio que maneja todas las operaciones CRUD relacionadas con los usuarios."""

    def __init__(self, db):
        self.collection = db['users']  # Asegúrate de que esta es la referencia correcta a la colección 'users'

    def create_user(self, data):
        """Crea un nuevo usuario en la base de datos."""
        try:
            # Verificar si ya existe un usuario con el mismo correo electrónico
            if self.get_user_by_email(data['email']):
                return {"error": "El correo electrónico ya está registrado."}

            # Cifrar la contraseña antes de insertar el usuario
            if 'password' in data:
                data['password'] = generate_password_hash(data['password'])

            # Insertar el usuario en la base de datos
            result = self.collection.insert_one(data)
            return str(result.inserted_id)
        except Exception as e:
            print(f"Error al crear usuario: {str(e)}")
            return {"error": "Error al crear usuario"}

    def update_user(self, user_id, data):
        """Actualiza la información de un usuario."""
        try:
            # Verificar si el usuario existe
            if not self.get_user_by_id(user_id):
                return {"error": "El usuario no existe."}

            # Cifrar la nueva contraseña si se está actualizando
            if 'password' in data:
                data['password'] = generate_password_hash(data['password'])

            result = self.collection.update_one({'_id': ObjectId(user_id)}, {'$set': data})
            return result.modified_count > 0
        except Exception as e:
            print(f"Error al actualizar usuario: {str(e)}")
            return {"error": "Error al actualizar usuario"}

    def delete_user(self, user_id):
        """Elimina un usuario de la base de datos."""
        try:
            # Verificar si el usuario existe antes de eliminarlo
            if not self.get_user_by_id(user_id):
                return {"error": "El usuario no existe."}

            result = self.collection.delete_one({'_id': ObjectId(user_id)})
            return result.deleted_count > 0
        except Exception as e:
            print(f"Error al eliminar usuario: {str(e)}")
            return {"error": "Error al eliminar usuario"}

    def get_user_by_id(self, user_id):
        """Obtiene un usuario por su ID."""
        try:
            user = self.collection.find_one({'_id': ObjectId(user_id)})
            if user:
                user['_id'] = str(user['_id'])  # Convertir ObjectId a string
            return user
        except Exception as e:
            print(f"Error al obtener usuario por ID: {str(e)}")
            return {"error": "Formato de ID no válido."}

    def get_user_by_email(self, email):
        """Obtiene un usuario por su correo electrónico."""
        try:
            # Usar find_one para buscar un usuario en la colección 'users'
            user = self.collection.find_one({'email': email})
            
            # Si el usuario es encontrado, convertir el _id a string
            if user:
                user['_id'] = str(user['_id'])
            return user
        except Exception as e:
            print(f"Error al obtener el usuario por email: {str(e)}")
            return None

    def get_all_users(self, page=1, limit=10):
        """Obtiene una lista paginada de todos los usuarios."""
        try:
            skip = (page - 1) * limit
            users = self.collection.find().skip(skip).limit(limit)
            return [{'_id': str(user['_id']), **user} for user in users]
        except Exception as e:
            print(f"Error al obtener lista de usuarios: {str(e)}")
            return {"error": "Error al obtener lista de usuarios"}

    def get_users_by_community(self, community_id, page=1, limit=10):
        """Obtiene una lista paginada de los usuarios que pertenecen a una comunidad."""
        try:
            skip = (page - 1) * limit
            users = self.collection.find({'communities': community_id}).skip(skip).limit(limit)
            return [{'_id': str(user['_id']), **user} for user in users]
        except Exception as e:
            print(f"Error al obtener usuarios por comunidad: {str(e)}")
            return {"error": "Error al obtener usuarios por comunidad"}

    def disable_user(self, user_id):
        """Deshabilita la cuenta de un usuario."""
        try:
            # Verificar si el usuario existe
            if not self.get_user_by_id(user_id):
                return {"error": "El usuario no existe."}

            result = self.collection.update_one({'_id': ObjectId(user_id)}, {'$set': {'is_active': False}})
            return result.modified_count > 0
        except Exception as e:
            print(f"Error al deshabilitar usuario: {str(e)}")
            return {"error": "Error al deshabilitar usuario"}

    def reset_password(self, user_id, new_password):
        """Actualiza la contraseña de un usuario."""
        try:
            # Verificar si el usuario existe
            if not self.get_user_by_id(user_id):
                return {"error": "El usuario no existe."}

            # Cifrar la nueva contraseña
            hashed_password = generate_password_hash(new_password)
            result = self.collection.update_one({'_id': ObjectId(user_id)}, {'$set': {'password': hashed_password}})
            return result.modified_count > 0
        except Exception as e:
            print(f"Error al actualizar la contraseña: {str(e)}")
            return {"error": "Error al actualizar la contraseña"}
