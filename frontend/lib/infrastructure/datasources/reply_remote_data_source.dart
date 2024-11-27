// relative path: frontend/lib/infrastructure/datasources/reply_remote_data_source.dart

import 'package:frontend/infrastructure/dto/reply_dto.dart';
import 'package:frontend/infrastructure/network/api_client.dart';

class ReplyRemoteDataSource {
  final ApiClient apiClient;

  ReplyRemoteDataSource(this.apiClient);

  /// Obtiene una respuesta por su ID.
  Future<ReplyDTO?> getReplyById(String id) async {
    try {
      final response = await apiClient.get('/api/replies/$id');
      if (response.statusCode == 200) {
        return ReplyDTO.fromJson(response.data);
      }
    } catch (e) {
      print('Error al obtener la respuesta por ID: $e');
    }
    return null;
  }

  /// Crea una nueva respuesta.
  Future<String?> createReply(ReplyDTO replyDto) async {
    try {
      final response =
          await apiClient.post('/api/replies', data: replyDto.toJson());
      if (response.statusCode == 201) {
        return response.data['reply_id'];
      }
    } catch (e) {
      print('Error al crear la respuesta: $e');
    }
    return null;
  }

  /// Actualiza una respuesta existente.
  Future<void> updateReply(String id, ReplyDTO replyDto) async {
    try {
      await apiClient.put('/api/replies/$id/update', data: replyDto.toJson());
    } catch (e) {
      print('Error al actualizar la respuesta: $e');
    }
  }

  /// Elimina una respuesta por su ID.
  Future<void> deleteReply(String id) async {
    try {
      await apiClient.delete('/api/replies/$id/delete');
    } catch (e) {
      print('Error al eliminar la respuesta: $e');
    }
  }

  /// Obtiene una lista de respuestas para un comentario específico con paginación.
  Future<List<ReplyDTO>> getRepliesByComment(
      String commentId, int page, int limit) async {
    try {
      final response = await apiClient.get(
        '/api/comments/$commentId/replies',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => ReplyDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener las respuestas del comentario: $e');
    }
    return [];
  }

  /// Da like a una respuesta.
  Future<void> likeReply(String replyId, String userId) async {
    try {
      await apiClient
          .post('/api/replies/$replyId/like', data: {'user_id': userId});
    } catch (e) {
      print('Error al dar like a la respuesta: $e');
    }
  }

  /// Obtiene la lista de usuarios que han dado like a una respuesta.
  Future<List<String>> getReplyLikes(String replyId) async {
    try {
      final response = await apiClient.get('/api/replies/$replyId/likes');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
    } catch (e) {
      print('Error al obtener los likes de la respuesta: $e');
    }
    return [];
  }

  
}
