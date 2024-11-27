// relative path: frontend/lib/application/use_cases/replies/get_replies_by_comment_use_case.dart

import 'package:frontend/domain/entities/reply.dart';
import 'package:frontend/domain/interfaces/reply_repository.dart';

class GetRepliesByCommentUseCase {
  final ReplyRepository _replyRepository;

  // Constructor que inicializa el repositorio de Reply
  GetRepliesByCommentUseCase(this._replyRepository);

  /// Ejecuta el caso de uso para obtener las respuestas de un comentario específico
  /// Devuelve una lista de `Reply` o lanza una excepción en caso de error
  Future<List<Reply>> execute(String commentId, int page, int limit) async {
    try {
      return await _replyRepository.getRepliesByComment(commentId, page, limit);
    } catch (e) {
      throw Exception('Error al obtener las respuestas del comentario: $e');
    }
  }
}
