from bson import ObjectId
from datetime import datetime, timezone

class Community:
    def __init__(self, name, description, community_admin_id, moderators=None, profile_image=None, media=None, tags=None, created_at=None, updated_at=None, id=None, members=None, blacklist=None):
        self.id = ObjectId() if id is None else ObjectId(id)  # Generar automáticamente si no está presente
        self.name = name
        self.description = description
        self.community_admin_id = ObjectId(community_admin_id)  # Administrador de la comunidad, no confundir con el administrador del sitio
        self.moderators = [ObjectId(m) for m in (moderators or [])]  # Lista de moderadores
        self.profile_image = profile_image  # Imagen de perfil de la comunidad
        self.media = media or []  # Archivos de media asociados a la comunidad (e.g., imágenes, videos)
        self.tags = tags or []  # Etiquetas o categorías adicionales
        self.members = [ObjectId(member) for member in (members or [])]  # Miembros de la comunidad
        self.blacklist = [ObjectId(user) for user in (blacklist or [])]  # Usuarios en la lista negra
        self.created_at = created_at or datetime.now(timezone.utc)  # Fecha de creación
        self.updated_at = updated_at or datetime.now(timezone.utc)  # Fecha de última actualización

    def to_dict(self):
        """Convierte el objeto Community a un diccionario."""
        return {
            'id': str(self.id),
            'name': self.name,
            'description': self.description,
            'community_admin_id': str(self.community_admin_id),
            'moderators': [str(moderator) for moderator in self.moderators],
            'profile_image': self.profile_image,
            'media': self.media,
            'tags': self.tags,
            'members': [str(member) for member in self.members],  # Lista de miembros
            'blacklist': [str(user) for user in self.blacklist],  # Lista negra
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
        }

    @staticmethod
    def from_dict(data):
        """Crea una instancia de Community a partir de un diccionario."""
        return Community(
            name=data.get('name'),
            description=data.get('description'),
            community_admin_id=data.get('community_admin_id'),
            moderators=data.get('moderators', []),
            profile_image=data.get('profile_image'),
            media=data.get('media', []),
            tags=data.get('tags', []),
            members=data.get('members', []),
            blacklist=data.get('blacklist', []),
            created_at=datetime.strptime(data.get('created_at'), '%Y-%m-%d %H:%M:%S') if data.get('created_at') else None,
            updated_at=datetime.strptime(data.get('updated_at'), '%Y-%m-%d %H:%M:%S') if data.get('updated_at') else None,
            id=data.get('id')  # Pasar el ID si está disponible
        )

    def update(self, data):
        """Actualiza los atributos de la comunidad basado en los datos proporcionados."""
        self.name = data.get('name', self.name)
        self.description = data.get('description', self.description)
        self.community_admin_id = ObjectId(data.get('community_admin_id', self.community_admin_id))
        self.moderators = [ObjectId(m) for m in data.get('moderators', self.moderators)]
        self.profile_image = data.get('profile_image', self.profile_image)
        self.media = data.get('media', self.media)
        self.tags = data.get('tags', self.tags)
        self.updated_at = datetime.now(timezone.utc)

    def add_member(self, user_id):
        """Añade un miembro a la comunidad si no está en la lista negra ni es miembro."""
        user_id = ObjectId(user_id)
        if user_id not in self.members and user_id not in self.blacklist:
            self.members.append(user_id)
            self.updated_at = datetime.now(timezone.utc)

    def remove_member(self, user_id):
        """Elimina a un miembro de la comunidad."""
        user_id = ObjectId(user_id)
        if user_id in self.members:
            self.members.remove(user_id)
            self.updated_at = datetime.now(timezone.utc)

    def add_to_blacklist(self, user_id):
        """Añade un usuario a la lista negra y lo elimina de la comunidad si es miembro."""
        user_id = ObjectId(user_id)
        if user_id not in self.blacklist:
            self.blacklist.append(user_id)
            self.remove_member(user_id)

    def remove_from_blacklist(self, user_id):
        """Elimina a un usuario de la lista negra."""
        user_id = ObjectId(user_id)
        if user_id in self.blacklist:
            self.blacklist.remove(user_id)
        self.updated_at = datetime.now(timezone.utc)

    def add_moderator(self, user_id):
        """Añade un moderador a la comunidad."""
        user_id = ObjectId(user_id)
        if user_id not in self.moderators:
            self.moderators.append(user_id)
            self.updated_at = datetime.now(timezone.utc)

    def remove_moderator(self, user_id):
        """Elimina a un moderador de la comunidad."""
        user_id = ObjectId(user_id)
        if user_id in self.moderators:
            self.moderators.remove(user_id)
        self.updated_at = datetime.now(timezone.utc)

    def can_user_join(self, user_id):
        """Verifica si un usuario puede unirse a la comunidad (no debe estar en la lista negra)."""
        return ObjectId(user_id) not in self.blacklist
