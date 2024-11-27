# relative path: app/infrastructure/web/user_controller.py

from datetime import timedelta
from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    jwt_required,
    get_jwt_identity,
    create_access_token,
    create_refresh_token,
)
from app.domain.user.use_cases import UserUseCases
from app.infrastructure.db import get_db_instance  # Asume que get_db_instance devuelve una instancia de la base de datos
from app.infrastructure.cache.redis_client import redis_client  # Importar cliente Redis
from app.infrastructure.websockets.socketio import socketio  # Importar instancia de SocketIO
from bson import ObjectId
import json

user_controller = Blueprint('user_controller', __name__)


def serialize_doc(doc):
    """
    Recursively convierte ObjectId en strings dentro de un documento.
    """
    if isinstance(doc, list):
        return [serialize_doc(item) for item in doc]
    elif isinstance(doc, dict):
        new_doc = {}
        for key, value in doc.items():
            if isinstance(value, ObjectId):
                new_doc[key] = str(value)
            elif isinstance(value, dict) or isinstance(value, list):
                new_doc[key] = serialize_doc(value)
            else:
                new_doc[key] = value
        return new_doc
    else:
        return doc


@user_controller.route('/api/users/register', methods=['POST'])
def register_user():
    db = get_db_instance()
    user_use_cases = UserUseCases(db)

    try:
        print("-> Inicio de solicitud de registro")
        print(f"Headers de la solicitud: {request.headers}")
        user_data = request.get_json()
        print(f"Datos recibidos: {user_data}")

        if not user_data:
            print("Error: Solicitud sin datos JSON.")
            return jsonify({"error": "Solicitud mal formateada"}), 400

        if 'password' not in user_data:
            print("Error: Contraseña faltante en la solicitud.")
            return jsonify({"error": "Contraseña requerida"}), 400

        result, status_code = user_use_cases.register_user(user_data)

        if "error" in result:
            print(f"Error durante el registro: {result['error']}")
            return jsonify(result), status_code  

        user_id = str(result['user_id']) if isinstance(result.get('user_id'), ObjectId) else result.get('user_id')

        # Serializar los tokens antes de almacenarlos en Redis
        access_token = result.get('access_token')
        refresh_token = result.get('refresh_token')

        redis_client.set(f"session:{user_id}", access_token, ex=3600)  # Expiración de 1 hora

        print(f"Usuario registrado con éxito: {result}")
        # Serializar el resultado antes de enviarlo
        serialized_result = serialize_doc(result)
        return jsonify(serialized_result), status_code

    except Exception as e:
        print(f"Error inesperado durante el registro: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route('/api/users/login', methods=['POST'])
def login_user():
    db = get_db_instance()
    user_use_cases = UserUseCases(db)

    try:
        print("-> Inicio de solicitud de login")
        print(f"Headers: {request.headers}")
        data = request.get_json()
        print(f"Datos recibidos: {data}")

        if not data:
            print("Error: Solicitud sin datos JSON.")
            return jsonify({"error": "Solicitud mal formateada o sin datos"}), 400

        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            print("Error: Email o contraseña faltantes.")
            return jsonify({"error": "Faltan credenciales"}), 400

        print(f"Intentando login con email: {email}")

        result, status_code = user_use_cases.login_user(email, password)
        print(f"Resultado de UserUseCases.login_user(): {result}, Status code: {status_code}")

        if "error" in result:
            print(f"Error en la autenticación: {result['error']}")
            return jsonify(result), status_code

        user_id = str(result['user_id']) if isinstance(result.get('user_id'), ObjectId) else result.get('user_id')
        access_token = result.get('access_token')
        refresh_token = result.get('refresh_token')

        redis_client.set(f"session:{user_id}", access_token, ex=3600)  # Expiración de 1 hora

        print(f"Login exitoso para {email}")
        # Serializar el resultado antes de enviarlo
        serialized_result = serialize_doc(result)
        return jsonify(serialized_result), status_code

    except Exception as e:
        print(f"Error inesperado durante el login: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route('/api/auth/refresh-token', methods=['POST'])
@jwt_required(refresh=True)
def refresh_token():
    try:
        user_id = get_jwt_identity()

        # Generar nuevo token
        new_access_token = create_access_token(identity=user_id, expires_delta=timedelta(hours=1))
        redis_client.set(f"session:{user_id}", new_access_token, ex=3600)

        return jsonify({"access_token": new_access_token}), 200
    except Exception as e:
        print(f"Error al refrescar el token: {e}")
        return jsonify({"error": "No se pudo refrescar el token"}), 401


@user_controller.route('/api/users/profile', methods=['GET'])
@jwt_required()
def get_user_profile():
    db = get_db_instance()
    user_use_cases = UserUseCases(db)

    user_id = get_jwt_identity()

    try:
        # Buscar en Redis primero
        cached_profile = redis_client.get(f"user_profile:{user_id}")
        if cached_profile:
            try:
                profile = json.loads(cached_profile)
                return jsonify(profile), 200
            except json.JSONDecodeError:
                pass  # Si hay un error en la decodificación, proceder a obtener desde la base de datos

        # Obtener el perfil del usuario si no está en caché
        user_profile = user_use_cases.get_user_profile(user_id)
        if user_profile:
            serialized_profile = serialize_doc(user_profile)
            redis_client.set(f"user_profile:{user_id}", json.dumps(serialized_profile), ex=60*10)  # Expiración en 10 minutos
            return jsonify(serialized_profile), 200
        else:
            return jsonify({"error": "Perfil no encontrado"}), 404
    except Exception as e:
        print(f"Error al obtener el perfil: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route('/api/users/update', methods=['PUT'])
@jwt_required()
def update_user_profile():
    db = get_db_instance()
    user_use_cases = UserUseCases(db)

    user_id = get_jwt_identity()
    new_data = request.get_json()

    try:
        result, status_code = user_use_cases.update_user_profile(user_id, new_data)
        if "error" in result:
            print(f"Error al actualizar el perfil: {result['error']}")
            return jsonify(result), status_code

        # Obtener el perfil actualizado
        updated_profile = user_use_cases.get_user_profile(user_id)
        serialized_profile = serialize_doc(updated_profile)
        redis_client.set(f"user_profile:{user_id}", json.dumps(serialized_profile), ex=60*10)  # Expiración en 10 minutos

        # Emitir notificación a través de WebSocket
        socketio.emit('profile_updated', {'user_id': user_id})

        return jsonify({"message": "Perfil actualizado exitosamente"}), status_code
    except Exception as e:
        print(f"Error al actualizar el perfil: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route('/api/users/reset-password', methods=['POST'])
def reset_password():
    db = get_db_instance()
    user_use_cases = UserUseCases(db)

    data = request.get_json()
    email = data.get('email')
    if not email:
        return jsonify({"error": "Correo electrónico requerido"}), 400

    try:
        result, status_code = user_use_cases.reset_password(email)
        return jsonify(result), status_code
    except Exception as e:
        print(f"Error inesperado durante el reseteo de contraseña: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route('/api/users/update-password', methods=['POST'])
def update_password():
    db = get_db_instance()
    user_use_cases = UserUseCases(db)

    data = request.get_json()
    user_id = data.get('user_id')
    new_password = data.get('new_password')

    if not user_id or not new_password:
        return jsonify({"error": "Datos incompletos"}), 400

    try:
        result, status_code = user_use_cases.update_password(user_id, new_password)
        if status_code == 200:
            # Emitir notificación a través de WebSocket
            socketio.emit('password_updated', {'user_id': user_id})

            return jsonify(result), status_code
        else:
            print(f"Error al actualizar la contraseña: {result.get('error')}")
            return jsonify(result), status_code
    except Exception as e:
        print(f"Error inesperado al actualizar la contraseña: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route('/api/users/disable', methods=['POST'])
@jwt_required()
def disable_user():
    db = get_db_instance()
    user_use_cases = UserUseCases(db)

    user_id = get_jwt_identity()

    try:
        result = user_use_cases.disable_user_account(user_id)
        if result:
            # Emitir notificación a través de WebSocket
            socketio.emit('account_disabled', {'user_id': user_id})

            # Eliminar la caché del perfil del usuario
            redis_client.delete(f"user_profile:{user_id}")

            return jsonify({"message": "Cuenta deshabilitada exitosamente"}), 200
        else:
            return jsonify({"error": "Error al deshabilitar la cuenta"}), 400
    except Exception as e:
        print(f"Error inesperado al deshabilitar la cuenta: {e}")
        return jsonify({"error": "Error interno del servidor"}), 500
