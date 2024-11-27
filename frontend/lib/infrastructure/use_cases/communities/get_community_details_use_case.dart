// relative path: frontend/lib/application/use_cases/communities/get_community_details_use_case.dart

import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/domain/interfaces/community_repository.dart';

class GetCommunityDetailsUseCase {
  final CommunityRepository communityRepository;

  GetCommunityDetailsUseCase(this.communityRepository);

  /// Obtiene los detalles de una comunidad por su ID.
  Future<Community?> execute(String communityId) async {
    try {
      return await communityRepository.getCommunityById(communityId);
    } catch (e) {
      throw Exception('Error al obtener los detalles de la comunidad: $e');
    }
  }
}
