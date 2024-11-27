// relative path: frontend/lib/application/use_cases/replies/get_reply_likes_use_case.dart

import 'package:frontend/domain/interfaces/reply_repository.dart';

class GetReplyLikesUseCase {
  final ReplyRepository _replyRepository;

  // Constructor que inicializa el repositorio de Reply
  GetReplyLikesUseCase(this._replyRepository);

  /// Ejecuta el caso de uso para obtener los likes de una respuesta específica.
  /// Devuelve una lista de IDs de usuarios que dieron like o lanza una excepción en caso de error.
  Future<List<String>> execute(String replyId) async {
    try {
      return await _replyRepository.getReplyLikes(replyId);
    } catch (e) {
      throw Exception('Error al obtener los likes de la respuesta: $e');
    }
  }
}
