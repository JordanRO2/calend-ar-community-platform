// frontend/lib/infrastructure/use_cases/communities/get_community_types_use_case.dart

import 'package:frontend/domain/interfaces/community_repository.dart';

class GetCommunityTypesUseCase {
  final CommunityRepository communityRepository;

  GetCommunityTypesUseCase(this.communityRepository);

  Future<List<String>> execute() async {
    try {
      return await communityRepository.getTypes();
    } catch (e) {
      throw Exception('Error al obtener tipos: $e');
    }
  }
}
