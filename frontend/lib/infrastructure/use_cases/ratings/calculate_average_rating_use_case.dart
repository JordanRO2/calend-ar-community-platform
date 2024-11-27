// relative path: frontend/lib/application/use_cases/ratings/calculate_average_rating_use_case.dart

import 'package:frontend/domain/interfaces/rating_repository.dart';

class CalculateAverageRatingUseCase {
  final RatingRepository ratingRepository;

  CalculateAverageRatingUseCase(this.ratingRepository);

  /// Ejecuta el cálculo de la puntuación promedio de un evento específico.
  Future<double> execute(String eventId) async {
    try {
      return await ratingRepository.calculateAverageRating(eventId);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al calcular la puntuación promedio del evento: $e');
      rethrow; // Re-lanza la excepción para manejo en la capa de presentación si es necesario
    }
  }
}
