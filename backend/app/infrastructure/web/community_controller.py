# relative path: app/infrastructure/web/community_controller.py

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from app.domain.community.use_cases import CommunityUseCases
from app.infrastructure.db import get_db_instance  # Asume que get_db_instance devuelve una instancia de la base de datos
from app.infrastructure.cache.redis_client import redis_client  # Cliente Redis configurado
from app.infrastructure.websockets.socketio import socketio  # Instancia de SocketIO
from bson import ObjectId
import json

community_controller = Blueprint('community_controller', __name__)

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
                
        # Asegurarse de que image_url esté presente
        if 'image_url' not in new_doc:
            new_doc['image_url'] = None  # O una URL por defecto
            
        return new_doc
    else:
        return doc
    
# Ruta para crear una nueva comunidad
@community_controller.route('/api/communities/create', methods=['POST'])
@jwt_required()
def create_community():
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    community_data = request.get_json()
    
    # Crear la comunidad
    result = community_use_cases.create_community(community_data)
    if "error" in result:
        return jsonify(result), 400
    
    # Obtener el ID de la comunidad creada
    community_id = str(result) if isinstance(result, ObjectId) else result
    
    # Emitir evento por WebSocket
    socketio.emit('community_created', {'community_id': community_id})
    
    # Serializar los datos antes de almacenarlos en Redis
    serialized_data = serialize_doc(community_data)
    redis_client.set(f"community:{community_id}", json.dumps(serialized_data))
    
    return jsonify({"message": "Comunidad creada exitosamente", "community_id": community_id}), 201

# Ruta para obtener los detalles de una comunidad
@community_controller.route('/api/communities/<community_id>', methods=['GET'])
def get_community_details(community_id):
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)

    # Buscar en Redis primero
    cached_community = redis_client.get(f"community:{community_id}")
    
    if cached_community:
        try:
            community = json.loads(cached_community)
            return jsonify(community), 200
        except json.JSONDecodeError:
            pass  # Si hay un error en la decodificación, proceder a buscar en la base de datos

    # Si no está en Redis, buscar en la base de datos
    community = community_use_cases.get_community_details(community_id)
    if not community:
        return jsonify({"error": "Comunidad no encontrada"}), 404

    # Serializar el documento
    serialized_community = serialize_doc(community)
    
    # Almacenar en Redis para la próxima vez
    redis_client.set(f"community:{community_id}", json.dumps(serialized_community))
    
    return jsonify(serialized_community), 200

# Ruta para actualizar los detalles de una comunidad existente
@community_controller.route('/api/communities/update/<community_id>', methods=['PUT'])
@jwt_required()
def update_community(community_id):
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    new_data = request.get_json()
    
    result = community_use_cases.update_community(community_id, new_data)
    if "error" in result:
        return jsonify(result), 400
    
    # Serializar los nuevos datos
    serialized_data = serialize_doc(result)
    
    # Actualizar en Redis después de actualizar en la base de datos
    redis_client.set(f"community:{community_id}", json.dumps(serialized_data))
    
    # Emitir evento por WebSocket que se actualizó una comunidad
    socketio.emit('community_updated', {"community_id": community_id})
    
    return jsonify({"message": "Comunidad actualizada exitosamente"}), 200

# Ruta para eliminar una comunidad
@community_controller.route('/api/communities/delete/<community_id>', methods=['DELETE'])
@jwt_required()
def delete_community(community_id):
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)

    result = community_use_cases.delete_community(community_id)
    if result:
        # Eliminar del cache Redis
        redis_client.delete(f"community:{community_id}")

        # Emitir evento por WebSocket que se eliminó una comunidad
        socketio.emit('community_deleted', {'community_id': community_id})

        return jsonify({"message": "Comunidad eliminada exitosamente"}), 200

    return jsonify({"error": "Error al eliminar la comunidad"}), 400

# Ruta para añadir un moderador a una comunidad
@community_controller.route('/api/communities/<community_id>/moderators/add', methods=['POST'])
@jwt_required()
def add_moderator(community_id):
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    data = request.get_json()
    user_id = data.get('user_id')
    
    if not user_id:
        return jsonify({"error": "user_id es requerido"}), 400

    result = community_use_cases.add_moderator_to_community(community_id, user_id)
    if result:
        # Convertir ObjectId a string si es necesario
        user_id_str = str(user_id) if isinstance(user_id, ObjectId) else user_id

        # Emitir evento por WebSocket
        socketio.emit('moderator_added', {'community_id': community_id, 'user_id': user_id_str})

        return jsonify({"message": "Moderador añadido exitosamente"}), 200

    return jsonify({"error": "Error al añadir el moderador"}), 400

# Ruta para eliminar un moderador de una comunidad
@community_controller.route('/api/communities/<community_id>/moderators/remove', methods=['POST'])
@jwt_required()
def remove_moderator(community_id):
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    data = request.get_json()
    user_id = data.get('user_id')
    
    if not user_id:
        return jsonify({"error": "user_id es requerido"}), 400

    result = community_use_cases.remove_moderator_from_community(community_id, user_id)
    if result:
        user_id_str = str(user_id) if isinstance(user_id, ObjectId) else user_id

        # Emitir evento por WebSocket
        socketio.emit('moderator_removed', {'community_id': community_id, 'user_id': user_id_str})

        return jsonify({"message": "Moderador eliminado exitosamente"}), 200

    return jsonify({"error": "Error al eliminar el moderador"}), 400

# Ruta para listar los miembros de una comunidad con paginación
@community_controller.route('/api/communities/<community_id>/members', methods=['GET'])
@jwt_required()
def list_community_members(community_id):
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    try:
        result = community_use_cases.list_community_members(community_id, page, limit)
        # Serializar los documentos antes de enviarlos
        serialized_result = [serialize_doc(member) for member in result]
        return jsonify(serialized_result if serialized_result else []), 200
    except Exception as e:
        print(f"Error en la ruta /api/communities/<community_id>/members: {str(e)}")
        return jsonify({"error": f"Error interno del servidor: {str(e)}"}), 500

# Ruta para obtener una lista de comunidades destacadas con paginación
@community_controller.route('/api/communities/featured', methods=['GET'])
def list_featured_communities():
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    try:
        # Obtener comunidades destacadas
        result = community_use_cases.get_featured_communities(page, limit)

        # Serializar los documentos antes de enviarlos
        serialized_result = [serialize_doc(community) for community in result]

        # Cambiar 404 por 200 con una lista vacía
        if not serialized_result:
            return jsonify([]), 200

        return jsonify(serialized_result), 200
    except Exception as e:
        print(f"Error en la ruta /api/communities/featured: {str(e)}")
        return jsonify({"error": f"Error interno del servidor: {str(e)}"}), 500

# Ruta para filtrar comunidades según criterios
@community_controller.route('/api/communities/filter', methods=['GET'])
def filter_communities():
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    filters = request.args.to_dict()
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    try:
        result = community_use_cases.filter_communities(filters, page, limit)
        # Serializar los documentos antes de enviarlos
        serialized_result = [serialize_doc(community) for community in result]
        return jsonify(serialized_result), 200
    except Exception as e:
        print(f"Error en la ruta /api/communities/filter: {str(e)}")
        return jsonify({"error": f"Error interno del servidor: {str(e)}"}), 500

# Ruta para listar todas las comunidades con paginación
@community_controller.route('/api/communities', methods=['GET'])
@jwt_required()
def list_all_communities():
    db = get_db_instance()
    community_use_cases = CommunityUseCases(db)
    
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 10, type=int)

    try:
        result = community_use_cases.list_all_communities(page, limit)
        
        # Serializar los documentos antes de enviarlos
        serialized_result = [serialize_doc(community) for community in result]
        
        # Asegurarse de que siempre devuelva una lista
        return jsonify(serialized_result if serialized_result else []), 200
    except Exception as e:
        print(f"Error en la ruta /api/communities: {str(e)}")
        return jsonify({"error": f"Error interno del servidor: {str(e)}"}), 500
