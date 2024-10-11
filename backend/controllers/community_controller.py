from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity

# Crear el Blueprint
community_controller = Blueprint('community_controller', __name__)

# Ruta para obtener una comunidad por ID
@community_controller.route('/communities/<community_id>', methods=['GET'])
@jwt_required()
def get_community(community_id):
    try:
        community_service = current_app.community_service
        community = community_service.get_community_by_id(community_id)
        if community:
            return jsonify(community.to_dict()), 200
        else:
            return jsonify({"error": "Comunidad no encontrada"}), 404
    except Exception as e:
        current_app.logger.error(f"Error al obtener comunidad {community_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para obtener todas las comunidades
@community_controller.route('/communities', methods=['GET'])
@jwt_required()
def get_all_communities():
    try:
        community_service = current_app.community_service
        communities = community_service.get_all_communities()
        return jsonify([community.to_dict() for community in communities]), 200
    except Exception as e:
        current_app.logger.error(f"Error al obtener comunidades: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para crear una nueva comunidad
@community_controller.route('/communities', methods=['POST'])
@jwt_required()
def create_community():
    try:
        community_data = request.get_json()
        if not community_data:
            return jsonify({"error": "No se proporcionaron datos"}), 400

        # Obtener el ID del usuario autenticado desde el JWT
        admin_user_id = get_jwt_identity()

        community_service = current_app.community_service
        new_community = community_service.create_community(community_data, admin_user_id)
        return jsonify(new_community.to_dict()), 201
    except ValueError as ve:
        current_app.logger.error(f"Error al crear comunidad: {str(ve)}")
        return jsonify({"error": str(ve)}), 400  # Error del cliente
    except Exception as e:
        current_app.logger.error(f"Error al crear comunidad: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para actualizar una comunidad por ID
@community_controller.route('/communities/<community_id>', methods=['PUT'])
@jwt_required()
def update_community(community_id):
    try:
        community_data = request.get_json()
        if not community_data:
            return jsonify({"error": "No se proporcionaron datos"}), 400

        # Obtener el ID del usuario autenticado desde el JWT
        user_id = get_jwt_identity()

        community_service = current_app.community_service
        updated_community = community_service.update_community(community_id, community_data, user_id)
        if updated_community:
            return jsonify(updated_community.to_dict()), 200
        else:
            return jsonify({"error": "Comunidad no encontrada"}), 404
    except ValueError as ve:
        current_app.logger.error(f"Error al actualizar comunidad {community_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 400  # Error del cliente
    except Exception as e:
        current_app.logger.error(f"Error al actualizar comunidad {community_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para eliminar una comunidad por ID
@community_controller.route('/communities/<community_id>', methods=['DELETE'])
@jwt_required()
def delete_community(community_id):
    try:
        # Obtener el ID del usuario autenticado desde el JWT
        admin_user_id = get_jwt_identity()

        community_service = current_app.community_service
        community_service.delete_community(community_id, admin_user_id)
        return jsonify({"message": "Comunidad eliminada exitosamente"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error al eliminar comunidad {community_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 400  # Error del cliente
    except Exception as e:
        current_app.logger.error(f"Error al eliminar comunidad {community_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para añadir un miembro a una comunidad
@community_controller.route('/communities/<community_id>/add_member', methods=['POST'])
@jwt_required()
def add_member(community_id):
    try:
        # Obtener el ID del usuario autenticado desde el JWT
        user_id = get_jwt_identity()

        community_service = current_app.community_service
        community_service.add_member(community_id, user_id)
        return jsonify({"message": "Usuario añadido a la comunidad"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error al agregar miembro a la comunidad {community_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        current_app.logger.error(f"Error al agregar miembro a la comunidad {community_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para expulsar un miembro de la comunidad
@community_controller.route('/communities/<community_id>/remove_member/<member_id>', methods=['DELETE'])
@jwt_required()
def remove_member(community_id, member_id):
    try:
        # Obtener el ID del usuario autenticado desde el JWT
        requester_id = get_jwt_identity()

        community_service = current_app.community_service
        community_service.remove_member(community_id, member_id, requester_id)
        return jsonify({"message": "Miembro eliminado de la comunidad"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error al eliminar miembro de la comunidad {community_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        current_app.logger.error(f"Error al eliminar miembro de la comunidad {community_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para añadir un miembro a la lista negra de una comunidad
@community_controller.route('/communities/<community_id>/blacklist_member/<member_id>', methods=['POST'])
@jwt_required()
def blacklist_member(community_id, member_id):
    try:
        # Obtener el ID del usuario autenticado desde el JWT
        requester_id = get_jwt_identity()

        community_service = current_app.community_service
        community_service.blacklist_member(community_id, member_id, requester_id)
        return jsonify({"message": "Miembro añadido a la lista negra"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error al agregar miembro a la lista negra {community_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        current_app.logger.error(f"Error al agregar miembro a la lista negra {community_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500
