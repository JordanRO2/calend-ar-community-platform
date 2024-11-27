from pymongo import MongoClient
from flask import current_app

def get_db_instance():
    """Establece y devuelve la conexión a la base de datos MongoDB utilizando la configuración de Flask."""
    
    # Obtener la URI de MongoDB desde la configuración de Flask
    mongo_uri = current_app.config['MONGODB_URI']
    
    # Establecer la conexión a MongoDB
    client = MongoClient(mongo_uri)
    
    # Obtener el nombre de la base de datos desde la configuración de Flask
    db_name = current_app.config.get('MONGODB_DB_NAME', 'Calendar') 
    
    # Obtener la instancia de la base de datos específica
    db = client[db_name]
    
    return db
