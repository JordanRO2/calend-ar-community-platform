from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from core.utils.auth_utils import admin_required


user_controller = Blueprint("user_controller", __name__)


@user_controller.route("/users", methods=["GET"])
@jwt_required()
@admin_required
def get_users():
    try:
        user_service = current_app.user_service
        users = user_service.get_all_users()
        return jsonify([user.to_dict() for user in users]), 200
    except Exception as e:
        current_app.logger.error(f"Error al obtener usuarios: {str(e)}")
        return jsonify({"error": str(e)}), 500


@user_controller.route("/users/<user_id>", methods=["GET"])
@jwt_required()
def get_user(user_id):
    try:
        user_service = current_app.user_service
        user = user_service.get_user_by_id(user_id)
        if user:
            user_data = user.to_dict()

            user_data.pop("password_hash", None)
            return jsonify(user_data), 200
        else:
            return jsonify({"error": "Usuario no encontrado"}), 404
    except Exception as e:
        current_app.logger.error(f"Error al obtener usuario {user_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500


@user_controller.route("/users/<user_id>", methods=["PUT"])
@jwt_required()
def update_user(user_id):
    try:
        user_data = request.get_json()
        if not user_data:
            return (
                jsonify({"error": "No se proporcionaron datos para la actualización"}),
                400,
            )

        user_service = current_app.user_service
        updated_user = user_service.update_user(user_id, user_data)
        if updated_user:
            user_data = updated_user.to_dict()

            user_data.pop("password_hash", None)
            return jsonify(user_data), 200
        else:
            return jsonify({"error": "Usuario no encontrado"}), 404
    except Exception as e:
        current_app.logger.error(f"Error al actualizar usuario {user_id}: {str(e)}")
        return jsonify({"error": str(e)}), 400


@user_controller.route("/users/<user_id>", methods=["DELETE"])
@jwt_required()
@admin_required
def delete_user(user_id):
    try:
        user_service = current_app.user_service
        user_service.delete_user(user_id)
        return jsonify({"message": "Usuario eliminado exitosamente"}), 200
    except Exception as e:
        current_app.logger.error(f"Error al eliminar usuario {user_id}: {str(e)}")
        return jsonify({"error": str(e)}), 400


@user_controller.route("/register", methods=["POST"])
def register_user():
    try:
        user_data = request.get_json()
        if not user_data:
            return jsonify({"error": "No se proporcionaron datos"}), 400

        username = user_data.get("username")
        password = user_data.get("password")
        email = user_data.get("email")

        if not username or not password or not email:
            return jsonify({"error": "Faltan campos requeridos"}), 400

        user_service = current_app.user_service

        if user_service.get_user_by_username(username):
            return jsonify({"error": "El nombre de usuario ya está en uso"}), 400
        if user_service.get_user_by_email(email):
            return jsonify({"error": "El correo electrónico ya está en uso"}), 400

        user_service.create_user(username, password, email)
        return jsonify({"message": "Usuario registrado exitosamente"}), 201
    except Exception as e:
        current_app.logger.error(f"Error al registrar usuario: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route("/login", methods=["POST"])
def login():
    try:
        if not request.is_json:
            return (
                jsonify({"error": "Se requiere un cuerpo de solicitud JSON válido"}),
                400,
            )

        username = request.json.get("username")
        password = request.json.get("password")

        if not username or not password:
            return jsonify({"error": "Se requiere nombre de usuario y contraseña"}), 400

        user_service = current_app.user_service
        user = user_service.authenticate_user(username, password)

        if user:
            access_token = create_access_token(identity=str(user.id))
            return jsonify({"access_token": access_token}), 200
        else:
            return jsonify({"error": "Credenciales inválidas"}), 401
    except Exception as e:
        current_app.logger.error(f"Error durante el inicio de sesión: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500


@user_controller.route("/me", methods=["GET"])
@jwt_required()
def get_me():
    try:
        user_id = get_jwt_identity()
        user_service = current_app.user_service
        user = user_service.get_user_by_id(user_id)
        if user:
            user_data = user.to_dict()
            user_data.pop("password_hash", None)
            return jsonify(user_data), 200
        else:
            return jsonify({"error": "Usuario no encontrado"}), 404
    except Exception as e:
        current_app.logger.error(f"Error al obtener los detalles del usuario: {str(e)}")
        return jsonify({"error": "Error interno del servidor"}), 500
