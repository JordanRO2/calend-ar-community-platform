// relative path: frontend/lib/application/use_cases/communities/remove_moderator_use_case.dart

import 'package:frontend/domain/interfaces/community_repository.dart';

class RemoveModeratorUseCase {
  final CommunityRepository communityRepository;

  RemoveModeratorUseCase(this.communityRepository);

  /// Elimina un moderador de una comunidad.
  Future<void> execute(String communityId, String userId) async {
    try {
      await communityRepository.removeModerator(communityId, userId);
    } catch (e) {
      throw Exception('Error al eliminar moderador de la comunidad: $e');
    }
  }
}
