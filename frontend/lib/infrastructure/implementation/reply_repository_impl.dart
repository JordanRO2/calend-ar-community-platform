// relative path: frontend/lib/infrastructure/implementation/reply_repository_impl.dart

import 'package:frontend/domain/entities/reply.dart';
import 'package:frontend/domain/interfaces/reply_repository.dart';
import 'package:frontend/infrastructure/datasources/reply_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/reply_mapper.dart';

class ReplyRepositoryImpl implements ReplyRepository {
  final ReplyRemoteDataSource remoteDataSource;

  // Constructor que inicializa la fuente de datos remota
  ReplyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Reply?> getReplyById(String id) async {
    try {
      final replyDto = await remoteDataSource.getReplyById(id);
      return replyDto != null ? ReplyMapper.fromDto(replyDto) : null;
    } catch (e) {
      throw Exception('Error al obtener la respuesta por ID: $e');
    }
  }

  @override
  Future<String?> createReply(Reply reply) async {
    try {
      final replyDto = ReplyMapper.toDto(reply);
      return await remoteDataSource.createReply(replyDto);
    } catch (e) {
      throw Exception('Error al crear la respuesta: $e');
    }
  }

  @override
  Future<void> updateReply(String id, Reply reply) async {
    try {
      final replyDto = ReplyMapper.toDto(reply);
      await remoteDataSource.updateReply(id, replyDto);
    } catch (e) {
      throw Exception('Error al actualizar la respuesta: $e');
    }
  }

  @override
  Future<void> deleteReply(String id) async {
    try {
      await remoteDataSource.deleteReply(id);
    } catch (e) {
      throw Exception('Error al eliminar la respuesta: $e');
    }
  }

  @override
  Future<List<Reply>> getRepliesByComment(
      String commentId, int page, int limit) async {
    try {
      final replyDtos =
          await remoteDataSource.getRepliesByComment(commentId, page, limit);
      return replyDtos
          .map((replyDto) => ReplyMapper.fromDto(replyDto))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener las respuestas del comentario: $e');
    }
  }

  @override
  Future<void> likeReply(String replyId, String userId) async {
    try {
      await remoteDataSource.likeReply(replyId, userId);
    } catch (e) {
      throw Exception('Error al dar like a la respuesta: $e');
    }
  }

  @override
  Future<List<String>> getReplyLikes(String replyId) async {
    try {
      return await remoteDataSource.getReplyLikes(replyId);
    } catch (e) {
      throw Exception('Error al obtener los likes de la respuesta: $e');
    }
  }


}
