// relative path: frontend/lib/application/use_cases/communities/delete_community_use_case.dart

import 'package:frontend/domain/interfaces/community_repository.dart';

class DeleteCommunityUseCase {
  final CommunityRepository communityRepository;

  DeleteCommunityUseCase(this.communityRepository);

  /// Elimina una comunidad existente por su ID.
  Future<void> execute(String communityId) async {
    try {
      await communityRepository.deleteCommunity(communityId);
    } catch (e) {
      throw Exception('Error al eliminar la comunidad: $e');
    }
  }
}
