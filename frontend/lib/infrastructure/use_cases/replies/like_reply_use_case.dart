// relative path: frontend/lib/application/use_cases/replies/like_reply_use_case.dart

import 'package:frontend/domain/interfaces/reply_repository.dart';

class LikeReplyUseCase {
  final ReplyRepository _replyRepository;

  // Constructor que inicializa el repositorio de Reply
  LikeReplyUseCase(this._replyRepository);

  /// Ejecuta el caso de uso para dar like a una respuesta específica
  /// No devuelve un valor, pero lanza una excepción en caso de error
  Future<void> execute(String replyId, String userId) async {
    try {
      await _replyRepository.likeReply(replyId, userId);
    } catch (e) {
      throw Exception('Error al dar like a la respuesta: $e');
    }
  }
}
