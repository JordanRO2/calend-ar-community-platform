// relative path: frontend/lib/application/use_cases/comments/update_comment_use_case.dart

import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/domain/interfaces/comment_repository.dart';

class UpdateCommentUseCase {
  final CommentRepository commentRepository;

  UpdateCommentUseCase(this.commentRepository);

  /// Actualiza los datos de un comentario existente.
  Future<void> execute(String commentId, Comment comment) async {
    try {
      await commentRepository.updateComment(commentId, comment);
    } catch (e) {
      throw Exception('Error al actualizar el comentario: $e');
    }
  }
}
