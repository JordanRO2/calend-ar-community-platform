// frontend/lib/infrastructure/use_cases/communities/get_community_locations_use_case.dart

import 'package:frontend/domain/interfaces/community_repository.dart';

class GetCommunityLocationsUseCase {
  final CommunityRepository communityRepository;

  GetCommunityLocationsUseCase(this.communityRepository);

  Future<List<String>> execute() async {
    try {
      return await communityRepository.getLocations();
    } catch (e) {
      throw Exception('Error al obtener ubicaciones: $e');
    }
  }
}
