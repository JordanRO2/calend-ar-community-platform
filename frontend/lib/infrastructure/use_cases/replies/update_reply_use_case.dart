// relative path: frontend/lib/application/use_cases/replies/update_reply_use_case.dart

import 'package:frontend/domain/entities/reply.dart';
import 'package:frontend/domain/interfaces/reply_repository.dart';

class UpdateReplyUseCase {
  final ReplyRepository _replyRepository;

  // Constructor que inicializa el repositorio de Reply
  UpdateReplyUseCase(this._replyRepository);

  /// Ejecuta el caso de uso para actualizar una respuesta
  /// No retorna un valor, pero maneja excepciones en caso de error
  Future<void> execute(String replyId, Reply updatedReply) async {
    try {
      await _replyRepository.updateReply(replyId, updatedReply);
    } catch (e) {
      throw Exception('Error al actualizar la respuesta: $e');
    }
  }
}
