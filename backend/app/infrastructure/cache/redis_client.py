# relative path: app/infrastructure/cache/redis_client.py

import redis
from app.core.config import Config  # Importar la configuración

class RedisClient:
    def __init__(self):
        redis_url = Config.REDIS_URL  # Obtener la URL de Redis desde la configuración
        self.client = redis.StrictRedis.from_url(redis_url, decode_responses=True)

    def get(self, key):
        """Obtiene un valor de Redis."""
        return self.client.get(key)

    def set(self, key, value, ex=None):
        """Guarda un valor en Redis con una opción de expiración."""
        return self.client.set(key, value, ex=ex)

    def delete(self, key):
        """Elimina un valor de Redis."""
        return self.client.delete(key)

# Instancia global del cliente Redis
redis_client = RedisClient().client
