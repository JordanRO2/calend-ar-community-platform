from flask import current_app
from core.domain.notification import NotificationStatus
from core.domain.community import Community

class CommunityService:
    def __init__(self, community_repository, user_repository, notification_service):
        self.community_repository = community_repository
        self.user_repository = user_repository
        self.notification_service = notification_service  # Conectar con el servicio de notificaciones

    def get_community_by_id(self, community_id):
        """Obtiene una comunidad por su ID."""
        try:
            return self.community_repository.get_by_id(community_id)
        except Exception as e:
            current_app.logger.error(f"Error al obtener comunidad: {str(e)}")
            raise Exception("Error al obtener la comunidad")

    def get_all_communities(self):
        """Obtiene todas las comunidades."""
        try:
            return self.community_repository.get_all()
        except Exception as e:
            current_app.logger.error(f"Error al obtener comunidades: {str(e)}")
            raise Exception("Error al obtener las comunidades")

    def create_community(self, community_data, admin_user_id):
        """Crea una nueva comunidad."""
        try:
            if community_data['community_admin_id'] != str(admin_user_id):
                raise ValueError("No tienes permisos para asignarte como administrador de esta comunidad.")

            existing_community = self.community_repository.get_by_name(community_data['name'])
            if existing_community:
                raise ValueError(f"El nombre de la comunidad '{community_data['name']}' ya está en uso.")

            moderators = community_data.get('moderators', [])
            for mod_id in moderators:
                if not self.user_repository.get_by_id(mod_id):
                    raise ValueError(f"El moderador con ID {mod_id} no es un usuario válido.")
                if mod_id == admin_user_id:
                    raise ValueError("El administrador no puede ser moderador.")

            community = Community(**community_data)
            self.community_repository.create(community)

            # Notificar al administrador de la comunidad
            notification_data = {
                'user_id': str(community.community_admin_id),
                'message': f"Has creado la comunidad '{community.name}'.",
                'status': NotificationStatus.UNREAD
            }
            self.notification_service.create_notification(notification_data)

            return community
        except ValueError as ve:
            current_app.logger.error(f"Error al crear comunidad: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al crear comunidad: {str(e)}")
            raise Exception("Error al crear la comunidad")

    def update_community(self, community_id, community_data, user_id):
        """Actualiza una comunidad existente."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("Comunidad no encontrada")

            if str(community.community_admin_id) != str(user_id) and str(user_id) not in community.moderators:
                raise ValueError("No tienes permisos para actualizar esta comunidad.")

            if 'name' in community_data and community_data['name'] != community.name:
                existing_community = self.community_repository.get_by_name(community_data['name'])
                if existing_community and str(existing_community.id) != str(community.id):
                    raise ValueError(f"El nombre de la comunidad '{community_data['name']}' ya está en uso.")

            moderators = community_data.get('moderators', community.moderators)
            for mod_id in moderators:
                if not self.user_repository.get_by_id(mod_id):
                    raise ValueError(f"El moderador con ID {mod_id} no es un usuario válido.")
                if mod_id not in community.moderators and str(community.community_admin_id) != str(user_id):
                    raise ValueError("Solo el administrador de la comunidad puede agregar moderadores.")

            community.update(community_data)
            self.community_repository.update(community)

            # Notificar a los miembros sobre la actualización de la comunidad
            for member_id in community.members:
                notification_data = {
                    'user_id': str(member_id),
                    'message': f"La comunidad '{community.name}' ha sido actualizada.",
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

            return community
        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar comunidad: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar comunidad: {str(e)}")
            raise Exception("Error al actualizar la comunidad")

    def delete_community(self, community_id, admin_user_id):
        """Elimina una comunidad."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("Comunidad no encontrada")

            if str(community.community_admin_id) != str(admin_user_id):
                raise ValueError("Solo el administrador de la comunidad puede eliminar la comunidad.")

            self.community_repository.delete(community_id)

            # Notificar a los miembros sobre la eliminación de la comunidad
            for member_id in community.members:
                notification_data = {
                    'user_id': str(member_id),
                    'message': f"La comunidad '{community.name}' ha sido eliminada.",
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

            current_app.logger.info(f"Comunidad {community_id} eliminada correctamente.")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar comunidad: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar comunidad: {str(e)}")
            raise Exception("Error al eliminar la comunidad")

    def add_member(self, community_id, user_id):
        """Añade un miembro a la comunidad."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("Comunidad no encontrada")

            if user_id not in community.members:
                community.members.append(user_id)
                self.community_repository.update(community)

                # Notificar al usuario de que ha sido añadido a la comunidad
                notification_data = {
                    'user_id': str(user_id),
                    'message': f"Te has unido a la comunidad '{community.name}'.",
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

                current_app.logger.info(f"Usuario {user_id} agregado a la comunidad {community_id}.")
            else:
                raise ValueError("El usuario ya es miembro de la comunidad.")
        except ValueError as ve:
            current_app.logger.error(f"Error al agregar miembro: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al agregar miembro: {str(e)}")
            raise Exception("Error al agregar miembro a la comunidad")

    def remove_member(self, community_id, user_id, requester_id):
        """Elimina un miembro de la comunidad."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("Comunidad no encontrada")

            if str(requester_id) not in community.moderators and str(community.community_admin_id) != str(requester_id):
                raise ValueError("No tienes permisos para eliminar miembros.")

            if user_id in community.members:
                community.members.remove(user_id)
                self.community_repository.update(community)

                # Notificar al usuario de que ha sido eliminado de la comunidad
                notification_data = {
                    'user_id': str(user_id),
                    'message': f"Has sido eliminado de la comunidad '{community.name}'.",
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

                current_app.logger.info(f"Usuario {user_id} eliminado de la comunidad {community_id}.")
            else:
                raise ValueError("El usuario no es miembro de la comunidad.")
        except ValueError as ve:
            current_app.logger.error(f"Error al eliminar miembro: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al eliminar miembro: {str(e)}")
            raise Exception("Error al eliminar miembro de la comunidad")

    def blacklist_member(self, community_id, user_id, requester_id):
        """Añade un miembro a la lista negra de la comunidad."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("Comunidad no encontrada")

            if str(requester_id) not in community.moderators and str(community.community_admin_id) != str(requester_id):
                raise ValueError("No tienes permisos para enviar miembros a la lista negra.")

            if user_id in community.members:
                community.members.remove(user_id)
                community.blacklist.append(user_id)
                self.community_repository.update(community)

                # Notificar al usuario de que ha sido añadido a la lista negra
                notification_data = {
                    'user_id': str(user_id),
                    'message': f"Has sido añadido a la lista negra de la comunidad '{community.name}'.",
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

                current_app.logger.info(f"Usuario {user_id} añadido a la lista negra de la comunidad {community_id}.")
            else:
                raise ValueError("El usuario no es miembro de la comunidad.")
        except ValueError as ve:
            current_app.logger.error(f"Error al agregar miembro a la lista negra: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al agregar miembro a la lista negra: {str(e)}")
            raise Exception("Error al agregar miembro a la lista negra")

    def update_community_settings(self, community_id, new_settings, user_id):
        """Actualiza la configuración de la comunidad y notifica a los miembros."""
        try:
            community = self.get_community_by_id(community_id)
            if not community:
                raise ValueError("Comunidad no encontrada")

            if str(user_id) not in [str(community.community_admin_id)] + community.moderators:
                raise ValueError("No tienes permiso para actualizar la configuración de la comunidad.")

            community.update(new_settings)
            self.community_repository.update(community)

            # Notificar a los miembros sobre los cambios
            for member_id in community.members:
                notification_data = {
                    'user_id': str(member_id),
                    'message': f"La configuración de la comunidad '{community.name}' ha sido actualizada.",
                    'status': NotificationStatus.UNREAD
                }
                self.notification_service.create_notification(notification_data)

        except ValueError as ve:
            current_app.logger.error(f"Error al actualizar configuración de la comunidad: {str(ve)}")
            raise ve
        except Exception as e:
            current_app.logger.error(f"Error al actualizar configuración de la comunidad: {str(e)}")
            raise Exception("Error al actualizar la configuración de la comunidad")
