// relative path: frontend/lib/application/use_cases/replies/create_reply_use_case.dart

import 'package:frontend/domain/entities/reply.dart';
import 'package:frontend/domain/interfaces/reply_repository.dart';

class CreateReplyUseCase {
  final ReplyRepository _replyRepository;

  // Constructor que inicializa el repositorio de Reply
  CreateReplyUseCase(this._replyRepository);

  /// Ejecuta el caso de uso para crear una respuesta
  /// Retorna el ID de la respuesta creada si es exitosa
  Future<String?> execute(Reply reply) async {
    try {
      return await _replyRepository.createReply(reply);
    } catch (e) {
      throw Exception('Error al crear la respuesta: $e');
    }
  }
}
