// frontend/lib/infrastructure/use_cases/communities/get_Community_categories_use_case.dart

import 'package:frontend/domain/interfaces/community_repository.dart';

class GetCommunityCategoriesUseCase {
  final CommunityRepository communityRepository;

  GetCommunityCategoriesUseCase(this.communityRepository);

  Future<List<String>> execute() async {
    try {
      return await communityRepository.getCategories();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }
}
