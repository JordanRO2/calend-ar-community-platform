// relative path: frontend/lib/infrastructure/datasources/comment_remote_data_source.dart

import 'package:frontend/infrastructure/dto/comment_dto.dart';
import 'package:frontend/infrastructure/network/api_client.dart';

class CommentRemoteDataSource {
  final ApiClient apiClient;

  CommentRemoteDataSource(this.apiClient);

  /// Obtiene un comentario por su ID.
  Future<CommentDTO?> getCommentById(String id) async {
    try {
      final response = await apiClient.get('/api/comments/$id');
      if (response.statusCode == 200) {
        return CommentDTO.fromJson(response.data);
      }
    } catch (e) {
      print('Error al obtener el comentario por ID: $e');
    }
    return null;
  }

  /// Crea un nuevo comentario.
  Future<String?> createComment(CommentDTO comment) async {
    try {
      final response =
          await apiClient.post('/api/comments/create', data: comment.toJson());
      if (response.statusCode == 201) {
        return response.data['comment_id'];
      }
    } catch (e) {
      print('Error al crear el comentario: $e');
    }
    return null;
  }

  /// Actualiza un comentario existente.
  Future<void> updateComment(String id, CommentDTO comment) async {
    try {
      await apiClient.put('/api/comments/update/$id', data: comment.toJson());
    } catch (e) {
      print('Error al actualizar el comentario: $e');
    }
  }

  /// Elimina un comentario por su ID.
  Future<void> deleteComment(String id) async {
    try {
      await apiClient.delete('/api/comments/delete/$id');
    } catch (e) {
      print('Error al eliminar el comentario: $e');
    }
  }

  /// Obtiene comentarios de un evento con paginación.
  Future<List<CommentDTO>> getCommentsByEvent(
      String eventId, int page, int limit) async {
    try {
      final response = await apiClient.get('/api/events/$eventId/comments',
          queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => CommentDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener comentarios del evento: $e');
    }
    return [];
  }

  /// Da like a un comentario.
  Future<void> likeComment(String commentId, String userId) async {
    try {
      await apiClient
          .post('/api/comments/$commentId/like', data: {'user_id': userId});
    } catch (e) {
      print('Error al dar like al comentario: $e');
    }
  }

  /// Obtiene la lista de usuarios que dieron like a un comentario.
  Future<List<String>> getCommentLikes(String commentId) async {
    try {
      final response = await apiClient.get('/api/comments/$commentId/likes');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
    } catch (e) {
      print('Error al obtener los likes del comentario: $e');
    }
    return [];
  }

  /// Reporta un comentario como inapropiado.
  Future<void> reportComment(
      String commentId, Map<String, dynamic> reportData) async {
    try {
      await apiClient.post('/api/comments/$commentId/report', data: reportData);
    } catch (e) {
      print('Error al reportar el comentario: $e');
    }
  }

  /// Obtiene una lista de comentarios reportados con paginación.
  Future<List<CommentDTO>> getReportedComments(int page, int limit) async {
    try {
      final response = await apiClient.get('/api/comments/reported',
          queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => CommentDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener comentarios reportados: $e');
    }
    return [];
  }
}
