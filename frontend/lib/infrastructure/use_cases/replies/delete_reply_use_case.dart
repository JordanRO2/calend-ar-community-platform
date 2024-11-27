// relative path: frontend/lib/application/use_cases/replies/delete_reply_use_case.dart

import 'package:frontend/domain/interfaces/reply_repository.dart';

class DeleteReplyUseCase {
  final ReplyRepository _replyRepository;

  // Constructor que inicializa el repositorio de Reply
  DeleteReplyUseCase(this._replyRepository);

  /// Ejecuta el caso de uso para eliminar una respuesta
  /// No retorna un valor, pero maneja excepciones en caso de error
  Future<void> execute(String replyId) async {
    try {
      await _replyRepository.deleteReply(replyId);
    } catch (e) {
      throw Exception('Error al eliminar la respuesta: $e');
    }
  }
}
