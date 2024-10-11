from bson import ObjectId
from flask import current_app
from core.domain.community import Community

class CommunityRepository:
    def __init__(self, db):
        self.communities = db.communities

    def get_by_id(self, community_id):
        """Obtiene una comunidad por su ID."""
        try:
            community_data = self.communities.find_one({'_id': ObjectId(community_id)})
            if community_data:
                community_data['id'] = str(community_data.pop('_id'))  # Convertir ObjectId a string
                return Community.from_dict(community_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener comunidad por ID {community_id}: {str(e)}")
            raise Exception("Error al obtener la comunidad")

    def get_by_name(self, name):
        """Obtiene una comunidad por su nombre."""
        try:
            community_data = self.communities.find_one({'name': name})
            if community_data:
                community_data['id'] = str(community_data.pop('_id'))  # Convertir ObjectId a string
                return Community.from_dict(community_data)
            return None
        except Exception as e:
            current_app.logger.error(f"Error al obtener comunidad por nombre {name}: {str(e)}")
            raise Exception("Error al obtener comunidad por nombre")

    def get_all(self):
        """Obtiene todas las comunidades."""
        try:
            community_list = []
            for community_data in self.communities.find():
                community_data['id'] = str(community_data.pop('_id'))  # Convertir ObjectId a string
                community_list.append(Community.from_dict(community_data))
            return community_list
        except Exception as e:
            current_app.logger.error(f"Error al obtener comunidades: {str(e)}")
            raise Exception("Error al obtener comunidades")

    def create(self, community):
        """Crea una nueva comunidad."""
        try:
            community_dict = community.to_dict()
            community_dict.pop('id')  # Eliminar 'id' ya que MongoDB maneja '_id'
            self.communities.insert_one(community_dict)
            current_app.logger.info(f"Comunidad '{community.name}' creada exitosamente.")
        except Exception as e:
            current_app.logger.error(f"Error al crear comunidad: {str(e)}")
            raise Exception("Error al crear la comunidad")

    def update(self, community):
        """Actualiza una comunidad existente."""
        try:
            community_dict = community.to_dict()
            community_dict['_id'] = ObjectId(community_dict.pop('id'))  # Convertir 'id' a ObjectId
            result = self.communities.update_one({'_id': community_dict['_id']}, {'$set': community_dict})
            if result.matched_count == 0:
                raise ValueError("Comunidad no encontrada")
            current_app.logger.info(f"Comunidad '{community.name}' actualizada exitosamente.")
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar comunidad {community.id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar comunidad {community.id}: {str(e)}")
            raise Exception("Error al actualizar la comunidad")

    def delete(self, community_id):
        """Elimina una comunidad por su ID."""
        try:
            result = self.communities.delete_one({'_id': ObjectId(community_id)})
            if result.deleted_count == 0:
                raise ValueError("Comunidad no encontrada")
            current_app.logger.info(f"Comunidad con ID '{community_id}' eliminada exitosamente.")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar comunidad {community_id}: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar comunidad {community_id}: {str(e)}")
            raise Exception("Error al eliminar la comunidad")

    # Añadir un miembro a la comunidad
    def add_member(self, community_id, user_id):
        try:
            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$addToSet': {'members': ObjectId(user_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Comunidad con ID {community_id} no encontrada")
            current_app.logger.info(f"Miembro con ID {user_id} añadido a la comunidad {community_id}")
        except Exception as e:
            current_app.logger.error(f"Error al añadir miembro a la comunidad {community_id}: {str(e)}")
            raise Exception(f"Error al añadir miembro a la comunidad {community_id}")

    # Eliminar un miembro de la comunidad
    def remove_member(self, community_id, user_id):
        try:
            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$pull': {'members': ObjectId(user_id)}}  # Eliminar miembro
            )
            if result.matched_count == 0:
                raise ValueError(f"Comunidad con ID {community_id} no encontrada")
            current_app.logger.info(f"Miembro con ID {user_id} eliminado de la comunidad {community_id}")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar miembro de la comunidad {community_id}: {str(e)}")
            raise Exception(f"Error al eliminar miembro de la comunidad {community_id}")

    # Añadir un moderador a la comunidad
    def add_moderator(self, community_id, user_id):
        try:
            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$addToSet': {'moderators': ObjectId(user_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Comunidad con ID {community_id} no encontrada")
            current_app.logger.info(f"Moderador con ID {user_id} añadido a la comunidad {community_id}")
        except Exception as e:
            current_app.logger.error(f"Error al añadir moderador a la comunidad {community_id}: {str(e)}")
            raise Exception(f"Error al añadir moderador a la comunidad {community_id}")

    # Eliminar un moderador de la comunidad
    def remove_moderator(self, community_id, user_id):
        try:
            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$pull': {'moderators': ObjectId(user_id)}}  # Eliminar moderador
            )
            if result.matched_count == 0:
                raise ValueError(f"Comunidad con ID {community_id} no encontrada")
            current_app.logger.info(f"Moderador con ID {user_id} eliminado de la comunidad {community_id}")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar moderador de la comunidad {community_id}: {str(e)}")
            raise Exception(f"Error al eliminar moderador de la comunidad {community_id}")

    # Añadir a un usuario a la lista negra de la comunidad
    def add_to_blacklist(self, community_id, user_id):
        try:
            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$addToSet': {'blacklist': ObjectId(user_id)}}  # Evitar duplicados
            )
            if result.matched_count == 0:
                raise ValueError(f"Comunidad con ID {community_id} no encontrada")
            current_app.logger.info(f"Usuario con ID {user_id} añadido a la lista negra de la comunidad {community_id}")
        except Exception as e:
            current_app.logger.error(f"Error al añadir usuario a la lista negra de la comunidad {community_id}: {str(e)}")
            raise Exception(f"Error al añadir usuario a la lista negra de la comunidad {community_id}")

    # Eliminar a un usuario de la lista negra de la comunidad
    def remove_from_blacklist(self, community_id, user_id):
        try:
            result = self.communities.update_one(
                {'_id': ObjectId(community_id)},
                {'$pull': {'blacklist': ObjectId(user_id)}}  # Eliminar de la lista negra
            )
            if result.matched_count == 0:
                raise ValueError(f"Comunidad con ID {community_id} no encontrada")
            current_app.logger.info(f"Usuario con ID {user_id} eliminado de la lista negra de la comunidad {community_id}")
        except Exception as e:
            current_app.logger.error(f"Error al eliminar usuario de la lista negra de la comunidad {community_id}: {str(e)}")
            raise Exception(f"Error al eliminar usuario de la lista negra de la comunidad {community_id}")
