// relative path: frontend/lib/application/use_cases/ratings/get_rating_by_id_use_case.dart

import 'package:frontend/domain/entities/rating.dart';
import 'package:frontend/domain/interfaces/rating_repository.dart';

class GetRatingByIdUseCase {
  final RatingRepository ratingRepository;

  GetRatingByIdUseCase(this.ratingRepository);

  /// Ejecuta la búsqueda de una puntuación específica por su ID.
  Future<Rating?> execute(String ratingId) async {
    try {
      return await ratingRepository.getRatingById(ratingId);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al obtener la puntuación por ID: $e');
      rethrow; // Re-lanza la excepción para permitir el manejo en la capa de presentación si es necesario
    }
  }
}
