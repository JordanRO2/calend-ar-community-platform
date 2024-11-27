// relative path: frontend/lib/application/use_cases/communities/filter_communities_use_case.dart

import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/domain/interfaces/community_repository.dart';

class FilterCommunitiesUseCase {
  final CommunityRepository communityRepository;

  FilterCommunitiesUseCase(this.communityRepository);

  /// Filtra las comunidades según los criterios especificados y con paginación.
  Future<List<Community>> execute(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      return await communityRepository.filterCommunities(filters, page, limit);
    } catch (e) {
      throw Exception('Error al filtrar las comunidades: $e');
    }
  }
}
