// relative path: frontend/lib/application/use_cases/replies/get_reply_by_id_use_case.dart

import 'package:frontend/domain/entities/reply.dart';
import 'package:frontend/domain/interfaces/reply_repository.dart';

class GetReplyByIdUseCase {
  final ReplyRepository _replyRepository;

  // Constructor que inicializa el repositorio de Reply
  GetReplyByIdUseCase(this._replyRepository);

  /// Ejecuta el caso de uso para obtener una respuesta por su ID
  /// Retorna una instancia de Reply si es exitosa
  Future<Reply?> execute(String replyId) async {
    try {
      return await _replyRepository.getReplyById(replyId);
    } catch (e) {
      throw Exception('Error al obtener la respuesta por ID: $e');
    }
  }
}
