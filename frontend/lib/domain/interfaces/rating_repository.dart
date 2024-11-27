// relative path: frontend/lib/domain/interfaces/rating_repository.dart

import 'package:frontend/domain/entities/rating.dart';

abstract class RatingRepository {
  /// Crea una nueva puntuación en la fuente de datos.
  Future<void> createRating(Rating rating);

  /// Actualiza una puntuación existente por su ID.
  Future<void> updateRating(String ratingId, Rating rating);

  /// Elimina una puntuación existente por su ID.
  Future<void> deleteRating(String ratingId);

  /// Obtiene una puntuación por su ID.
  Future<Rating?> getRatingById(String ratingId);

  /// Lista las puntuaciones de un evento específico con soporte para paginación.
  Future<List<Rating>> getRatingsByEvent(String eventId,
      {int page = 1, int limit = 10});

  /// Calcula el puntaje promedio para un evento específico.
  Future<double> calculateAverageRating(String eventId);
}
