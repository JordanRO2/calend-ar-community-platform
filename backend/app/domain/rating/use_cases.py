# relative path: app/domain/rating/use_cases.py

from marshmallow import ValidationError
from .repositories import RatingRepository
from .entities import RatingSchema

class RatingUseCases:
    """Clase que define los casos de uso para la entidad Rating."""

    def __init__(self, db):
        self.rating_repository = RatingRepository(db)
        self.rating_schema = RatingSchema()

    def create_rating(self, rating_data):
        """Crea una nueva puntuación."""
        try:
            # Validar los datos de la puntuación utilizando Marshmallow
            validated_data = self.rating_schema.load(rating_data)
            rating_id = self.rating_repository.create_rating(validated_data)
            return {"message": "Puntuación creada exitosamente", "rating_id": rating_id}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def update_rating(self, rating_id, new_data):
        """Actualiza los detalles de una puntuación."""
        try:
            # Validar los nuevos datos de la puntuación
            validated_data = self.rating_schema.load(new_data, partial=True)
            updated = self.rating_repository.update_rating(rating_id, validated_data)
            if updated:
                return {"message": "Puntuación actualizada exitosamente"}
            return {"error": "Error al actualizar la puntuación"}
        except ValidationError as e:
            return {"error": e.messages}
        except Exception as ex:
            return {"error": str(ex)}

    def delete_rating(self, rating_id):
        """Elimina una puntuación."""
        try:
            deleted = self.rating_repository.delete_rating(rating_id)
            if deleted:
                return {"message": "Puntuación eliminada exitosamente"}
            return {"error": "Error al eliminar la puntuación"}
        except Exception as ex:
            return {"error": str(ex)}

    def get_rating_details(self, rating_id):
        """Obtiene los detalles de una puntuación."""
        try:
            rating = self.rating_repository.get_rating_by_id(rating_id)
            if rating:
                return rating
            return {"error": "Puntuación no encontrada"}
        except Exception as ex:
            return {"error": str(ex)}

    def list_event_ratings(self, event_id, page=1, limit=10):
        """Lista las puntuaciones de un evento."""
        try:
            return self.rating_repository.get_ratings_by_event(event_id, page, limit)
        except Exception as ex:
            return {"error": str(ex)}

    def calculate_event_average_rating(self, event_id):
        """Calcula la puntuación promedio de un evento."""
        try:
            average = self.rating_repository.calculate_average_rating(event_id)
            if average is not None:
                return {"average_rating": average}
            return {"error": "No se pudo calcular la puntuación promedio"}
        except Exception as ex:
            return {"error": str(ex)}
