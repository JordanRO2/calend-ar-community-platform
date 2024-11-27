// relative path: frontend/lib/application/use_cases/comments/report_comment_use_case.dart

import 'package:frontend/domain/interfaces/comment_repository.dart';

class ReportCommentUseCase {
  final CommentRepository commentRepository;

  ReportCommentUseCase(this.commentRepository);

  /// Reporta un comentario inapropiado.
  Future<void> execute(String commentId, Map<String, dynamic> reportData) async {
    try {
      await commentRepository.reportComment(commentId, reportData);
    } catch (e) {
      throw Exception('Error al reportar el comentario: $e');
    }
  }
}
