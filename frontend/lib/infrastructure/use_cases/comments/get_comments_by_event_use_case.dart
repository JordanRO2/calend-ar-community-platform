// relative path: frontend/lib/application/use_cases/comments/get_comments_by_event_use_case.dart

import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/domain/interfaces/comment_repository.dart';

class GetCommentsByEventUseCase {
  final CommentRepository commentRepository;

  GetCommentsByEventUseCase(this.commentRepository);

  /// Obtiene una lista de comentarios de un evento con paginación.
  Future<List<Comment>> execute(String eventId, int page, int limit) async {
    try {
      return await commentRepository.getCommentsByEvent(eventId, page, limit);
    } catch (e) {
      throw Exception('Error al obtener los comentarios del evento: $e');
    }
  }
}
