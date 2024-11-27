// relative path: frontend/lib/application/use_cases/communities/get_featured_communities_use_case.dart

import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/domain/interfaces/community_repository.dart';

class GetFeaturedCommunitiesUseCase {
  final CommunityRepository communityRepository;

  GetFeaturedCommunitiesUseCase(this.communityRepository);

  /// Obtiene una lista de comunidades destacadas con paginación.
  Future<List<Community>> execute(int page, int limit) async {
    try {
      return await communityRepository.getFeaturedCommunities(page, limit);
    } catch (e) {
      throw Exception('Error al obtener las comunidades destacadas: $e');
    }
  }
}
