// relative path: frontend/lib/application/use_cases/ratings/get_ratings_by_event_use_case.dart

import 'package:frontend/domain/entities/rating.dart';
import 'package:frontend/domain/interfaces/rating_repository.dart';

class GetRatingsByEventUseCase {
  final RatingRepository ratingRepository;

  GetRatingsByEventUseCase(this.ratingRepository);

  /// Ejecuta la obtención de todas las puntuaciones de un evento específico con paginación.
  Future<List<Rating>> execute(String eventId,
      {int page = 1, int limit = 10}) async {
    try {
      return await ratingRepository.getRatingsByEvent(eventId,
          page: page, limit: limit);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al obtener las puntuaciones del evento: $e');
      rethrow; // Re-lanza la excepción para permitir el manejo en la capa de presentación si es necesario
    }
  }
}
