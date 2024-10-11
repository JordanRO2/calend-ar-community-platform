from bson import ObjectId
from datetime import datetime

class User:
    def __init__(
        self,
        username,
        email,
        password_hash,
        id=None,
        profile_image=None,
        is_admin=False,
        community_ids=None,
        calendar_id=None,
        gender=None,
        first_name=None,
        last_name=None,
        birthdate=None,
        country=None,
        state=None,
        city=None,
    ):
        self.id = ObjectId() if id is None else ObjectId(id)
        self.username = username
        self.email = email
        self.password_hash = password_hash
        self.profile_image = (
            profile_image or "https://yourdomain.com/default_profile.png"
        )
        self.is_admin = is_admin
        self.community_ids = community_ids or []
        self.calendar_id = calendar_id
        self.first_name = first_name
        self.last_name = last_name
        self.gender = gender
        self.birthdate = birthdate
        self.country = country
        self.state = state
        self.city = city
        self.notifications = []  # Almacena IDs de notificaciones relacionadas

    def to_dict(self):
        """Convierte el objeto User a un diccionario."""
        return {
            "id": str(self.id),
            "username": self.username,
            "email": self.email,
            "password_hash": self.password_hash,
            "profile_image": self.profile_image,
            "is_admin": self.is_admin,
            "community_ids": [str(cid) for cid in self.community_ids],
            "calendar_id": str(self.calendar_id) if self.calendar_id else None,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "gender": self.gender,
            "birthdate": self.birthdate,
            "country": self.country,
            "state": self.state,
            "city": self.city,
            "notifications": [str(n) for n in self.notifications],  # Lista de notificaciones
        }

    def update(self, data):
        """Actualiza los atributos del usuario basado en un diccionario de datos."""
        self.username = data.get("username", self.username)
        self.email = data.get("email", self.email)
        if "password_hash" in data:
            self.password_hash = data["password_hash"]
        self.profile_image = data.get("profile_image", self.profile_image)
        self.is_admin = data.get("is_admin", self.is_admin)
        self.community_ids = data.get("community_ids", self.community_ids)
        self.calendar_id = data.get("calendar_id", self.calendar_id)
        self.first_name = data.get("first_name", self.first_name)
        self.last_name = data.get("last_name", self.last_name)
        self.gender = data.get("gender", self.gender)
        self.birthdate = data.get("birthdate", self.birthdate)
        self.country = data.get("country", self.country)
        self.state = data.get("state", self.state)
        self.city = data.get("city", self.city)

    def add_community(self, community_id):
        """Añade una comunidad al usuario."""
        if community_id not in self.community_ids:
            self.community_ids.append(ObjectId(community_id))

    def remove_community(self, community_id):
        """Elimina una comunidad del usuario."""
        if ObjectId(community_id) in self.community_ids:
            self.community_ids.remove(ObjectId(community_id))

    def add_notification(self, notification_id):
        """Añade una notificación al usuario."""
        if notification_id not in self.notifications:
            self.notifications.append(ObjectId(notification_id))

    def clear_notifications(self):
        """Limpia la lista de notificaciones del usuario."""
        self.notifications = []

    def check_password(self, hashed_password):
        """Verifica si el hash proporcionado coincide con el almacenado."""
        return self.password_hash == hashed_password
