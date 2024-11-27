// frontend/lib/domain/interfaces/community_repository.dart

import 'package:frontend/domain/entities/community.dart';

abstract class CommunityRepository {
  Future<Community?> getCommunityById(String id);
  Future<List<Community>> getAllCommunities(int page, int limit);
  Future<String?> createCommunity(Community community);
  Future<void> updateCommunity(String id, Community community);
  Future<void> deleteCommunity(String id);
  Future<void> addModerator(String communityId, String userId);
  Future<void> removeModerator(String communityId, String userId);
  Future<List<Community>> getFeaturedCommunities(int page, int limit);
  Future<List<Community>> filterCommunities(
      Map<String, dynamic> filters, int page, int limit);
  Future<List<String>> getTypes();
  Future<List<String>> getCategories();
  Future<List<String>> getLocations();
}
