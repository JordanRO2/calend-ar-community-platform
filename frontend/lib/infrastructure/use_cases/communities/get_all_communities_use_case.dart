// relative path: frontend/lib/application/use_cases/communities/get_all_communities_use_case.dart

import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/domain/interfaces/community_repository.dart';

class GetAllCommunitiesUseCase {
  final CommunityRepository communityRepository;

  GetAllCommunitiesUseCase(this.communityRepository);

  /// Obtiene una lista de todas las comunidades con paginación.
  Future<List<Community>> execute(int page, int limit) async {
    try {
      return await communityRepository.getAllCommunities(page, limit);
    } catch (e) {
      throw Exception('Error al obtener todas las comunidades: $e');
    }
  }
}
