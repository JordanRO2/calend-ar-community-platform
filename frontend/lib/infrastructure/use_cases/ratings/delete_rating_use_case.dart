// relative path: frontend/lib/application/use_cases/ratings/delete_rating_use_case.dart

import 'package:frontend/domain/interfaces/rating_repository.dart';

class DeleteRatingUseCase {
  final RatingRepository ratingRepository;

  DeleteRatingUseCase(this.ratingRepository);

  /// Ejecuta la eliminación de una puntuación específica por su ID.
  Future<void> execute(String ratingId) async {
    try {
      await ratingRepository.deleteRating(ratingId);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al eliminar la puntuación: $e');
      rethrow; // Re-lanza la excepción para permitir el manejo en la capa de presentación si es necesario
    }
  }
}
