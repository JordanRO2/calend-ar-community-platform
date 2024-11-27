// relative path: frontend/lib/application/use_cases/ratings/create_rating_use_case.dart

import 'package:frontend/domain/entities/rating.dart';
import 'package:frontend/domain/interfaces/rating_repository.dart';

class CreateRatingUseCase {
  final RatingRepository ratingRepository;

  CreateRatingUseCase(this.ratingRepository);

  /// Ejecuta la creación de una nueva puntuación.
  Future<void> execute(Rating rating) async {
    try {
      await ratingRepository.createRating(rating);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al crear la puntuación: $e');
      rethrow; // Re-lanza la excepción para manejarla en la capa de presentación si es necesario
    }
  }
}
