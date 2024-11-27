// relative path: frontend/lib/application/use_cases/communities/create_community_use_case.dart

import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/domain/interfaces/community_repository.dart';

class CreateCommunityUseCase {
  final CommunityRepository communityRepository;

  CreateCommunityUseCase(this.communityRepository);

  /// Crea una nueva comunidad y devuelve su ID.
  Future<String> execute(Community community) async {
    try {
      final communityId = await communityRepository.createCommunity(community);
      if (communityId == null) {
        throw Exception('Error al crear la comunidad: ID no recibido.');
      }
      return communityId;
    } catch (e) {
      throw Exception('Error al crear la comunidad: $e');
    }
  }
}
