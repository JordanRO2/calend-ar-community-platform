// relative path: frontend/lib/application/use_cases/comments/get_comment_details_use_case.dart

import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/domain/interfaces/comment_repository.dart';

class GetCommentDetailsUseCase {
  final CommentRepository commentRepository;

  GetCommentDetailsUseCase(this.commentRepository);

  /// Obtiene los detalles de un comentario por ID.
  Future<Comment?> execute(String commentId) async {
    try {
      return await commentRepository.getCommentById(commentId);
    } catch (e) {
      throw Exception('Error al obtener los detalles del comentario: $e');
    }
  }
}
