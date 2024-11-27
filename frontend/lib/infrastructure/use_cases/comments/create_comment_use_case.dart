// relative path: frontend/lib/application/use_cases/comments/create_comment_use_case.dart

import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/domain/interfaces/comment_repository.dart';

class CreateCommentUseCase {
  final CommentRepository commentRepository;

  CreateCommentUseCase(this.commentRepository);

  /// Crea un nuevo comentario y retorna el ID del comentario creado.
  Future<String> execute(Comment comment) async {
    try {
      final commentId = await commentRepository.createComment(comment);
      return commentId ?? (throw Exception('Error al crear el comentario'));
    } catch (e) {
      throw Exception('Error al crear el comentario: $e');
    }
  }
}
