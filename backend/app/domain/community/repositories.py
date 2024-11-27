from pymongo import MongoClient
from bson.objectid import ObjectId

class CommunityRepository:
    """Repositorio que maneja todas las operaciones CRUD relacionadas con las comunidades."""

    def __init__(self, db: MongoClient):
        self.communities = db.communities  # Colección de comunidades en MongoDB

    def create_community(self, data):
        """Crea una nueva comunidad en la base de datos."""
        try:
            # Asegurarse de que image_url esté presente en los datos
            if 'image_url' not in data:
                data['image_url'] = None  # O una URL por defecto
                
            result = self.communities.insert_one(data)
            return str(result.inserted_id)
        except Exception as e:
            print(f"Error en create_community: {e}")
            raise Exception("Error al crear la comunidad")

    def update_community(self, community_id, data):
        """Actualiza los detalles de una comunidad."""
        try:
            if not self.get_community_by_id(community_id):
                raise ValueError("La comunidad no existe.")

            result = self.communities.update_one({'_id': ObjectId(community_id)}, {'$set': data})
            return result.modified_count > 0
        except Exception as e:
            print(f"Error en update_community: {e}")
            raise Exception("Error al actualizar la comunidad")

    def delete_community(self, community_id):
        """Elimina una comunidad de la base de datos."""
        try:
            if not self.get_community_by_id(community_id):
                raise ValueError("La comunidad no existe.")

            result = self.communities.delete_one({'_id': ObjectId(community_id)})
            return result.deleted_count > 0
        except Exception as e:
            print(f"Error en delete_community: {e}")
            raise Exception("Error al eliminar la comunidad")

    def get_community_by_id(self, community_id):
        """Obtiene una comunidad por su ID."""
        try:
            community = self.communities.find_one({'_id': ObjectId(community_id)})
            if community:
                community['_id'] = str(community['_id'])
            return community
        except Exception as e:
            print(f"Error en get_community_by_id: {e}")
            raise Exception("Error al obtener la comunidad por ID")

    def get_all_communities(self, page=1, limit=10):
        """Obtiene una lista paginada de todas las comunidades."""
        try:
            skip = (page - 1) * limit
            communities = self.communities.find().skip(skip).limit(limit)
            return [{'_id': str(community['_id']), **community} for community in communities]
        except Exception as e:
            print(f"Error en get_all_communities: {e}")
            raise Exception("Error al obtener todas las comunidades")

    def add_moderator(self, community_id, user_id):
        """Agrega un moderador a una comunidad."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("La comunidad no existe.")

            if user_id in community.get('moderators', []):
                raise ValueError("El usuario ya es moderador de esta comunidad.")

            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$addToSet': {'moderators': user_id}}
            )
            return result.modified_count > 0
        except Exception as e:
            print(f"Error en add_moderator: {e}")
            raise Exception("Error al agregar moderador")

    def remove_moderator(self, community_id, user_id):
        """Elimina a un moderador de una comunidad."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("La comunidad no existe.")

            if user_id not in community.get('moderators', []):
                raise ValueError("El usuario no es moderador de esta comunidad.")

            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$pull': {'moderators': user_id}}
            )
            return result.modified_count > 0
        except Exception as e:
            print(f"Error en remove_moderator: {e}")
            raise Exception("Error al eliminar moderador")

    def get_featured_communities(self, page=1, limit=10):
        """Devuelve una lista paginada de comunidades destacadas."""
        try:
            skip = (page - 1) * limit
            featured_communities = self.communities.find({'featured': True}).skip(skip).limit(limit)
            return [{'_id': str(community['_id']), **community} for community in featured_communities]
        except Exception as e:
            print(f"Error en get_featured_communities: {e}")
            raise Exception("Error al obtener comunidades destacadas")

    def filter_communities(self, filters, page=1, limit=10):
        """Filtra las comunidades según los filtros proporcionados con paginación."""
        try:
            query = {}
            if 'category' in filters:
                query['category'] = filters['category']
            if 'location' in filters:
                query['location'] = filters['location']
            if 'type' in filters:
                query['type'] = filters['type']
            if 'popularity' in filters:
                query['popularity'] = {'$gte': filters['popularity']}
            if 'participation' in filters:
                query['participation'] = {'$gte': filters['participation']}

            skip = (page - 1) * limit
            communities = self.communities.find(query).skip(skip).limit(limit)
            return [{'_id': str(community['_id']), **community} for community in communities]
        except Exception as e:
            print(f"Error en filter_communities: {e}")
            raise Exception("Error al filtrar comunidades")
