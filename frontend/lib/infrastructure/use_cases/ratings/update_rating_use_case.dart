// relative path: frontend/lib/application/use_cases/ratings/update_rating_use_case.dart

import 'package:frontend/domain/entities/rating.dart';
import 'package:frontend/domain/interfaces/rating_repository.dart';

class UpdateRatingUseCase {
  final RatingRepository ratingRepository;

  UpdateRatingUseCase(this.ratingRepository);

  /// Ejecuta la actualización de una puntuación existente.
  Future<void> execute(String ratingId, Rating rating) async {
    try {
      await ratingRepository.updateRating(ratingId, rating);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al actualizar la puntuación: $e');
      rethrow; // Re-lanza la excepción para permitir su manejo en la capa de presentación
    }
  }
}
