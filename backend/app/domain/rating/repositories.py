# relative path: app/domain/rating/repositories.py

from pymongo import MongoClient
from bson.objectid import ObjectId

class RatingRepository:
    """Repositorio que maneja todas las operaciones CRUD relacionadas con las puntuaciones."""

    def __init__(self, db: MongoClient):
        self.ratings = db.ratings  # Colección de puntuaciones en MongoDB

    def create_rating(self, data):
        """Crea una nueva puntuación en la base de datos."""
        # Validar si el usuario ya ha dado una puntuación para el mismo evento
        existing_rating = self.ratings.find_one({
            'event': data['event'],
            'user': data['user']
        })
        if existing_rating:
            return {"error": "El usuario ya ha puntuado este evento."}

        result = self.ratings.insert_one(data)
        return str(result.inserted_id)

    def update_rating(self, rating_id, data):
        """Actualiza una puntuación en la base de datos."""
        # Validar si la puntuación existe
        if not self.get_rating_by_id(rating_id):
            return {"error": "La puntuación no existe."}

        result = self.ratings.update_one({'_id': ObjectId(rating_id)}, {'$set': data})
        return result.modified_count > 0

    def delete_rating(self, rating_id):
        """Elimina una puntuación de la base de datos."""
        # Validar si la puntuación existe
        if not self.get_rating_by_id(rating_id):
            return {"error": "La puntuación no existe."}

        result = self.ratings.delete_one({'_id': ObjectId(rating_id)})
        return result.deleted_count > 0

    def get_rating_by_id(self, rating_id):
        """Obtiene una puntuación por su ID."""
        try:
            rating = self.ratings.find_one({'_id': ObjectId(rating_id)})
            if rating:
                rating['_id'] = str(rating['_id'])
            return rating
        except Exception:
            return {"error": "Formato de ID no válido."}

    def get_ratings_by_event(self, event_id, page=1, limit=10):
        """Obtiene una lista paginada de puntuaciones para un evento."""
        skip = (page - 1) * limit
        ratings = self.ratings.find({'event': event_id}).skip(skip).limit(limit)
        return [{'_id': str(rating['_id']), **rating} for rating in ratings]

    def calculate_average_rating(self, event_id):
        """Calcula la puntuación promedio de un evento."""
        pipeline = [
            {'$match': {'event': event_id}},
            {'$group': {'_id': '$event', 'average_rating': {'$avg': '$score'}}}
        ]
        result = list(self.ratings.aggregate(pipeline))
        if result:
            return result[0]['average_rating']
        return 0.0
