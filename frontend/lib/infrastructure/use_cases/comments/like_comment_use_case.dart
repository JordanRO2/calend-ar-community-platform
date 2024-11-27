// relative path: frontend/lib/application/use_cases/comments/like_comment_use_case.dart

import 'package:frontend/domain/interfaces/comment_repository.dart';

class LikeCommentUseCase {
  final CommentRepository commentRepository;

  LikeCommentUseCase(this.commentRepository);

  /// Da like a un comentario.
  Future<void> execute(String commentId, String userId) async {
    try {
      await commentRepository.likeComment(commentId, userId);
    } catch (e) {
      throw Exception('Error al dar like al comentario: $e');
    }
  }
}
