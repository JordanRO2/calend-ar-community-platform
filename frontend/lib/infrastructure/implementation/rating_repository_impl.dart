// relative path: frontend/lib/infrastructure/implementation/rating_repository_impl.dart

import 'package:frontend/domain/entities/rating.dart';
import 'package:frontend/domain/interfaces/rating_repository.dart';
import 'package:frontend/infrastructure/datasources/rating_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/rating_mapper.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;

  RatingRepositoryImpl(this.remoteDataSource);

  /// Crea una nueva puntuación en la fuente de datos remota.
  @override
  Future<void> createRating(Rating rating) async {
    final ratingDto = RatingMapper.toDto(rating);
    await remoteDataSource.createRating(ratingDto);
  }

  /// Actualiza una puntuación existente en la fuente de datos remota.
  @override
  Future<void> updateRating(String ratingId, Rating rating) async {
    final ratingDto = RatingMapper.toDto(rating);
    await remoteDataSource.updateRating(ratingId, ratingDto);
  }

  /// Elimina una puntuación existente en la fuente de datos remota.
  @override
  Future<void> deleteRating(String ratingId) async {
    await remoteDataSource.deleteRating(ratingId);
  }

  /// Obtiene una puntuación específica por su ID desde la fuente de datos remota.
  @override
  Future<Rating?> getRatingById(String ratingId) async {
    final ratingDto = await remoteDataSource.getRatingById(ratingId);
    return ratingDto != null ? RatingMapper.fromDto(ratingDto) : null;
  }

  /// Obtiene todas las puntuaciones de un evento específico desde la fuente de datos remota.
  @override
  Future<List<Rating>> getRatingsByEvent(String eventId,
      {int page = 1, int limit = 10}) async {
    final ratingDtos = await remoteDataSource.getRatingsByEvent(eventId,
        page: page, limit: limit);
    return ratingDtos.map(RatingMapper.fromDto).toList();
  }

  /// Calcula la puntuación promedio de un evento específico desde la fuente de datos remota.
  @override
  Future<double> calculateAverageRating(String eventId) async {
    return await remoteDataSource.calculateAverageRating(eventId);
  }
}
