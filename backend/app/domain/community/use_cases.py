from marshmallow import ValidationError
from .repositories import CommunityRepository
from .entities import CommunitySchema
from app.domain.event.repositories import EventRepository  # Repositorio de eventos
from app.domain.user.repositories import UserRepository  # Repositorio de usuarios

class CommunityUseCases:
    """Clase que define los casos de uso para la entidad Community."""

    def __init__(self, db):
        self.community_repository = CommunityRepository(db)
        self.community_schema = CommunitySchema()
        self.event_repository = EventRepository(db)  # Inicializa el repositorio de eventos
        self.user_repository = UserRepository(db)  # Inicializa el repositorio de usuarios

    def create_community(self, community_data):
        """Crea una nueva comunidad."""
        try:
            # Validar los datos de la comunidad utilizando Marshmallow
            validated_data = self.community_schema.load(community_data)
            community_id = self.community_repository.create_community(validated_data)
            return {"community_id": community_id}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def update_community(self, community_id, new_data):
        """Actualiza la información de una comunidad."""
        try:
            # Validar los nuevos datos
            validated_data = self.community_schema.load(new_data, partial=True)
            updated = self.community_repository.update_community(community_id, validated_data)
            if updated:
                return {"message": "Comunidad actualizada exitosamente"}
            return {"error": "Error al actualizar la comunidad"}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def delete_community(self, community_id):
        """Elimina una comunidad."""
        try:
            deleted = self.community_repository.delete_community(community_id)
            if deleted:
                return {"message": "Comunidad eliminada exitosamente"}
            return {"error": "Error al eliminar la comunidad"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_community_details(self, community_id):
        """Obtiene los detalles de una comunidad."""
        try:
            community = self.community_repository.get_community_by_id(community_id)
            if community:
                return community
            return {"error": "Comunidad no encontrada"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_all_communities(self, page, limit):
        """
        Lista todas las comunidades con paginación.
        """
        try:
            # Obtener comunidades desde el repositorio
            communities = self.community_repository.get_all_communities(page, limit)
            
            # Garantizar que siempre se devuelva una lista
            return communities if communities else []
        except Exception as ex:
            print(f"Error en list_all_communities: {str(ex)}")
            return {"error": "Error al listar comunidades"}

    def get_featured_communities(self, page=1, limit=10):
        """Obtiene una lista paginada de comunidades destacadas."""
        try:
            communities = self.community_repository.get_featured_communities(page, limit)
            return communities if communities else []
        except Exception as ex:
            return {"error": str(ex)}
