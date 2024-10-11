from flask import Blueprint, request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity

# Crear el Blueprint para los comentarios
comment_controller = Blueprint('comment_controller', __name__)

# Ruta para obtener comentarios por ID de evento (con paginación)
@comment_controller.route('/events/<event_id>/comments', methods=['GET'])
@jwt_required(optional=True)
def get_comments(event_id):
    try:
        page = int(request.args.get('page', 1))  # Número de página (predeterminado: 1)
        per_page = int(request.args.get('per_page', 10))  # Comentarios por página (predeterminado: 10)

        comment_service = current_app.comment_service
        comments = comment_service.get_comments_by_event_id(event_id, page, per_page)

        return jsonify({
            'comments': [comment.to_dict() for comment in comments],
            'page': page,
            'per_page': per_page,
        }), 200
    except Exception as e:
        current_app.logger.error(f"Error al obtener comentarios para el evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para agregar un nuevo comentario
@comment_controller.route('/events/<event_id>/comments', methods=['POST'])
@jwt_required()
def add_comment(event_id):
    try:
        comment_data = request.get_json()

        if not comment_data or 'text' not in comment_data:
            return jsonify({"error": "No se proporcionaron datos válidos para el comentario"}), 400

        # Obtener el ID del usuario a partir del token JWT
        user_id = get_jwt_identity()
        comment_data['user_id'] = user_id
        comment_data['event_id'] = event_id

        comment_service = current_app.comment_service
        new_comment = comment_service.add_comment(comment_data)

        return jsonify(new_comment.to_dict()), 201
    except ValueError as ve:
        current_app.logger.error(f"Error de validación al agregar comentario: {str(ve)}")
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        current_app.logger.error(f"Error al agregar comentario para el evento {event_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para eliminar un comentario por su ID (solo autor o admin)
@comment_controller.route('/comments/<comment_id>', methods=['DELETE'])
@jwt_required()
def delete_comment(comment_id):
    try:
        # Obtener el ID del usuario autenticado
        user_id = get_jwt_identity()

        comment_service = current_app.comment_service
        comment_service.delete_comment(comment_id, user_id)

        return jsonify({"message": "Comentario eliminado exitosamente"}), 200
    except ValueError as ve:
        current_app.logger.error(f"Error de validación al eliminar comentario {comment_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        current_app.logger.error(f"Error al eliminar comentario {comment_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500

# Ruta para actualizar un comentario (solo autor puede actualizar)
@comment_controller.route('/comments/<comment_id>', methods=['PUT'])
@jwt_required()
def update_comment(comment_id):
    try:
        comment_data = request.get_json()

        if not comment_data or 'text' not in comment_data:
            return jsonify({"error": "No se proporcionaron datos válidos para actualizar el comentario"}), 400

        # Obtener el ID del usuario autenticado
        user_id = get_jwt_identity()

        comment_service = current_app.comment_service
        updated_comment = comment_service.update_comment(comment_id, user_id, comment_data['text'])

        return jsonify(updated_comment.to_dict()), 200
    except ValueError as ve:
        current_app.logger.error(f"Error de validación al actualizar comentario {comment_id}: {str(ve)}")
        return jsonify({"error": str(ve)}), 400
    except Exception as e:
        current_app.logger.error(f"Error al actualizar comentario {comment_id}: {str(e)}")
        return jsonify({"error": str(e)}), 500
