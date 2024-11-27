// relative path: frontend/lib/application/use_cases/comments/get_comment_likes_use_case.dart

import 'package:frontend/domain/interfaces/comment_repository.dart';

class GetCommentLikesUseCase {
  final CommentRepository commentRepository;

  GetCommentLikesUseCase(this.commentRepository);

  /// Obtiene una lista de IDs de usuarios que han dado like a un comentario.
  Future<List<String>> execute(String commentId) async {
    try {
      return await commentRepository.getCommentLikes(commentId);
    } catch (e) {
      throw Exception('Error al obtener los likes del comentario: $e');
    }
  }
}
