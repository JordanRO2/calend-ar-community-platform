// relative path: frontend/lib/application/use_cases/communities/update_community_use_case.dart

import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/domain/interfaces/community_repository.dart';

class UpdateCommunityUseCase {
  final CommunityRepository communityRepository;

  UpdateCommunityUseCase(this.communityRepository);

  /// Actualiza los datos de una comunidad existente.
  Future<void> execute(String communityId, Community updatedCommunity) async {
    try {
      await communityRepository.updateCommunity(communityId, updatedCommunity);
    } catch (e) {
      throw Exception('Error al actualizar la comunidad: $e');
    }
  }
}
