# relative path: app/core/config.py

import os
from dotenv import load_dotenv
from datetime import timedelta

# Cargar las variables de entorno desde el archivo .env
load_dotenv()

class Config:
    """Configuración general del proyecto."""

    # Configuración de MongoDB (Docker)
    MONGODB_URI = os.getenv('MONGODB_URI', 'mongodb://mongo:27017/calendario_comunitario')

    # Configuración de JWT
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'clave_secreta_por_defecto')
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(seconds=int(os.getenv('JWT_ACCESS_TOKEN_EXPIRES', 3600)))
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=int(os.getenv('JWT_REFRESH_TOKEN_EXPIRES', 30)))

    # Configuración de Redis (Docker) para WebSockets y colas de tareas
    REDIS_URL = os.getenv('REDIS_URL', 'redis://redis:6379/0')

    # Configuración general de seguridad y llaves
    SECRET_KEY = os.getenv('SECRET_KEY', 'una_clave_secreta_defecto')

    # Configuración de los hosts permitidos
    ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '*').split(',')

    # Otras configuraciones generales
    DEBUG = False
    TESTING = False

class DevelopmentConfig(Config):
    """Configuración para el entorno de desarrollo."""
    DEBUG = True
    MONGODB_URI = os.getenv('DEV_MONGODB_URI', Config.MONGODB_URI)
    REDIS_URL = os.getenv('DEV_REDIS_URL', Config.REDIS_URL)

class ProductionConfig(Config):
    """Configuración para el entorno de producción."""
    DEBUG = False
    MONGODB_URI = os.getenv('PROD_MONGODB_URI', Config.MONGODB_URI)
    REDIS_URL = os.getenv('PROD_REDIS_URL', Config.REDIS_URL)
    TESTING = False

# Selección de la configuración adecuada según el entorno
config_by_name = {
    'development': DevelopmentConfig,
    'production': ProductionConfig
}
