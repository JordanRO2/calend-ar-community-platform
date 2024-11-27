// relative path: frontend/lib/infrastructure/mappers/rating_mapper.dart

import 'package:frontend/domain/entities/rating.dart';
import 'package:frontend/infrastructure/dto/rating_dto.dart';

class RatingMapper {
  /// Convierte de Rating (dominio) a RatingDTO (infraestructura).
  static RatingDTO toDto(Rating rating) {
    return RatingDTO(
      id: rating.id,
      event: rating.event,
      user: rating.user,
      score: rating.score,
      createdAt: rating.createdAt,
    );
  }

  /// Convierte de RatingDTO (infraestructura) a Rating (dominio).
  static Rating fromDto(RatingDTO dto) {
    return Rating(
      id: dto.id ?? '',
      event: dto.event,
      user: dto.user,
      score: dto.score,
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }
}
