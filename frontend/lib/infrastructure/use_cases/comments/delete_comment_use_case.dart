// relative path: frontend/lib/application/use_cases/comments/delete_comment_use_case.dart

import 'package:frontend/domain/interfaces/comment_repository.dart';

class DeleteCommentUseCase {
  final CommentRepository commentRepository;

  DeleteCommentUseCase(this.commentRepository);

  /// Elimina un comentario por ID.
  Future<void> execute(String commentId) async {
    try {
      await commentRepository.deleteComment(commentId);
    } catch (e) {
      throw Exception('Error al eliminar el comentario: $e');
    }
  }
}
