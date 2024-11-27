// relative path: frontend/lib/infrastructure/datasources/rating_remote_data_source.dart

import 'package:frontend/infrastructure/network/api_client.dart';
import 'package:frontend/infrastructure/dto/rating_dto.dart';

class RatingRemoteDataSource {
  final ApiClient apiClient;

  RatingRemoteDataSource(this.apiClient);

  /// Crea una nueva puntuación en el backend.
  Future<void> createRating(RatingDTO rating) async {
    try {
      await apiClient.post('/api/ratings/create', data: rating.toJson());
    } catch (e) {
      print('Error al crear la puntuación: $e');
      rethrow;
    }
  }

  /// Actualiza una puntuación existente en el backend.
  Future<void> updateRating(String ratingId, RatingDTO rating) async {
    try {
      await apiClient.put('/api/ratings/update/$ratingId',
          data: rating.toJson());
    } catch (e) {
      print('Error al actualizar la puntuación: $e');
      rethrow;
    }
  }

  /// Elimina una puntuación existente en el backend.
  Future<void> deleteRating(String ratingId) async {
    try {
      await apiClient.delete('/api/ratings/delete/$ratingId');
    } catch (e) {
      print('Error al eliminar la puntuación: $e');
      rethrow;
    }
  }

  /// Obtiene una puntuación específica por su ID.
  Future<RatingDTO?> getRatingById(String ratingId) async {
    try {
      final response = await apiClient.get('/api/ratings/$ratingId');
      if (response.statusCode == 200) {
        return RatingDTO.fromJson(response.data);
      }
    } catch (e) {
      print('Error al obtener la puntuación por ID: $e');
    }
    return null;
  }

  /// Obtiene todas las puntuaciones de un evento específico, con soporte para paginación.
  Future<List<RatingDTO>> getRatingsByEvent(String eventId,
      {int page = 1, int limit = 10}) async {
    try {
      final response =
          await apiClient.get('/api/ratings/event/$eventId', queryParameters: {
        'page': page,
        'limit': limit,
      });
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => RatingDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener las puntuaciones del evento: $e');
    }
    return [];
  }

  /// Calcula la puntuación promedio de un evento específico.
  Future<double> calculateAverageRating(String eventId) async {
    try {
      final response =
          await apiClient.get('/api/ratings/event/$eventId/average');
      if (response.statusCode == 200) {
        return response.data['average_rating'] ?? 0.0;
      }
    } catch (e) {
      print('Error al calcular la puntuación promedio: $e');
    }
    return 0.0;
  }
}
