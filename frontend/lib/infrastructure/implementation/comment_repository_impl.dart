// relative path: frontend/lib/infrastructure/implementation/comment_repository_impl.dart

import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/domain/interfaces/comment_repository.dart';
import 'package:frontend/infrastructure/datasources/comment_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/comment_mapper.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;

  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Comment?> getCommentById(String id) async {
    try {
      final commentDto = await remoteDataSource.getCommentById(id);
      return commentDto != null ? CommentMapper.fromDto(commentDto) : null;
    } catch (e) {
      throw Exception('Error al obtener el comentario: $e');
    }
  }

  @override
  Future<String?> createComment(Comment comment) async {
    try {
      final commentDto = CommentMapper.toDto(comment);
      return await remoteDataSource.createComment(commentDto);
    } catch (e) {
      throw Exception('Error al crear el comentario: $e');
    }
  }

  @override
  Future<void> updateComment(String id, Comment comment) async {
    try {
      final commentDto = CommentMapper.toDto(comment);
      await remoteDataSource.updateComment(id, commentDto);
    } catch (e) {
      throw Exception('Error al actualizar el comentario: $e');
    }
  }

  @override
  Future<void> deleteComment(String id) async {
    try {
      await remoteDataSource.deleteComment(id);
    } catch (e) {
      throw Exception('Error al eliminar el comentario: $e');
    }
  }

  @override
  Future<List<Comment>> getCommentsByEvent(
      String eventId, int page, int limit) async {
    try {
      final commentDtos =
          await remoteDataSource.getCommentsByEvent(eventId, page, limit);
      return commentDtos.map(CommentMapper.fromDto).toList();
    } catch (e) {
      throw Exception('Error al obtener los comentarios del evento: $e');
    }
  }

  @override
  Future<void> likeComment(String commentId, String userId) async {
    try {
      await remoteDataSource.likeComment(commentId, userId);
    } catch (e) {
      throw Exception('Error al dar like al comentario: $e');
    }
  }

  @override
  Future<List<String>> getCommentLikes(String commentId) async {
    try {
      return await remoteDataSource.getCommentLikes(commentId);
    } catch (e) {
      throw Exception('Error al obtener los likes del comentario: $e');
    }
  }

  @override
  Future<void> reportComment(
      String commentId, Map<String, dynamic> reportData) async {
    try {
      await remoteDataSource.reportComment(commentId, reportData);
    } catch (e) {
      throw Exception('Error al reportar el comentario: $e');
    }
  }

  @override
  Future<List<Comment>> getReportedComments(int page, int limit) async {
    try {
      final commentDtos =
          await remoteDataSource.getReportedComments(page, limit);
      return commentDtos.map(CommentMapper.fromDto).toList();
    } catch (e) {
      throw Exception('Error al obtener los comentarios reportados: $e');
    }
  }
}
