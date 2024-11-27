// relative path: frontend/lib/application/use_cases/comments/get_reported_comments_use_case.dart

import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/domain/interfaces/comment_repository.dart';

class GetReportedCommentsUseCase {
  final CommentRepository commentRepository;

  GetReportedCommentsUseCase(this.commentRepository);

  /// Obtiene una lista de comentarios reportados con paginación.
  Future<List<Comment>> execute(int page, int limit) async {
    try {
      return await commentRepository.getReportedComments(page, limit);
    } catch (e) {
      throw Exception('Error al obtener los comentarios reportados: $e');
    }
  }
}
