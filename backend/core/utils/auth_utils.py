from flask import current_app
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from functools import wraps

def admin_required(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        # Verificar si el usuario tiene un JWT válido
        verify_jwt_in_request()

        # Obtener la identidad del JWT
        user_id = get_jwt_identity()

        # Obtener el servicio de usuario desde current_app
        user_service = current_app.user_service
        user = user_service.get_user_by_id(user_id)

        if not user or not user.is_admin:
            return {"error": "Acceso denegado, se requiere ser administrador"}, 403

        return fn(*args, **kwargs)
    
    return wrapper
