// relative path: frontend/lib/application/use_cases/communities/add_moderator_use_case.dart

import 'package:frontend/domain/interfaces/community_repository.dart';

class AddModeratorUseCase {
  final CommunityRepository communityRepository;

  AddModeratorUseCase(this.communityRepository);

  /// Añade un moderador a una comunidad.
  Future<void> execute(String communityId, String userId) async {
    try {
      await communityRepository.addModerator(communityId, userId);
    } catch (e) {
      throw Exception('Error al añadir moderador a la comunidad: $e');
    }
  }
}
