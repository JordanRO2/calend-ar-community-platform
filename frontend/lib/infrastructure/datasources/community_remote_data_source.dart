// frontend/lib/infrastructure/datasources/community_remote_data_source.dart

import 'package:frontend/infrastructure/dto/community_dto.dart';
import 'package:frontend/infrastructure/network/api_client.dart';

class CommunityRemoteDataSource {
  final ApiClient apiClient;

  CommunityRemoteDataSource(this.apiClient);

  Future<CommunityDTO?> getCommunityById(String id) async {
    try {
      final response = await apiClient.get('/api/communities/$id');
      if (response.statusCode == 200) {
        return CommunityDTO.fromJson(response.data);
      }
    } catch (e) {
      print('Error al obtener la comunidad por ID: $e');
    }
    return null;
  }

  Future<List<CommunityDTO>> getAllCommunities(int page, int limit) async {
    try {
      final response = await apiClient.get('/api/communities',
          queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => CommunityDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener todas las comunidades: $e');
    }
    return [];
  }

  Future<String?> createCommunity(CommunityDTO community) async {
    try {
      final response = await apiClient.post('/api/communities/create',
          data: community.toJson());
      if (response.statusCode == 201) {
        return response.data['community_id'];
      }
    } catch (e) {
      print('Error al crear la comunidad: $e');
    }
    return null;
  }

  Future<void> updateCommunity(String id, CommunityDTO community) async {
    try {
      await apiClient.put('/api/communities/update/$id',
          data: community.toJson());
    } catch (e) {
      print('Error al actualizar la comunidad: $e');
    }
  }

  Future<void> deleteCommunity(String id) async {
    try {
      await apiClient.delete('/api/communities/delete/$id');
    } catch (e) {
      print('Error al eliminar la comunidad: $e');
    }
  }

  Future<void> addModerator(String communityId, String userId) async {
    try {
      await apiClient.post('/api/communities/$communityId/moderators/add',
          data: {'user_id': userId});
    } catch (e) {
      print('Error al añadir moderador a la comunidad: $e');
    }
  }

  Future<void> removeModerator(String communityId, String userId) async {
    try {
      await apiClient.post('/api/communities/$communityId/moderators/remove',
          data: {'user_id': userId});
    } catch (e) {
      print('Error al eliminar moderador de la comunidad: $e');
    }
  }

  Future<List<CommunityDTO>> getFeaturedCommunities(int page, int limit) async {
    try {
      final response = await apiClient.get('/api/communities/featured',
          queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => CommunityDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener comunidades destacadas: $e');
    }
    return [];
  }

  Future<List<CommunityDTO>> filterCommunities(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      final response = await apiClient.get('/api/communities/filter',
          queryParameters: {...filters, 'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => CommunityDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al filtrar comunidades: $e');
    }
    return [];
  }

  Future<List<String>> getTypes() async {
    try {
      final response = await apiClient.get('/api/communities/types');
      if (response.statusCode == 200) {
        return List<String>.from(response.data['types']);
      }
    } catch (e) {
      print('Error al obtener tipos: $e');
    }
    return [];
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await apiClient.get('/api/communities/categories');
      if (response.statusCode == 200) {
        return List<String>.from(response.data['categories']);
      }
    } catch (e) {
      print('Error al obtener categorías: $e');
    }
    return [];
  }

  Future<List<String>> getLocations() async {
    try {
      final response = await apiClient.get('/api/communities/locations');
      if (response.statusCode == 200) {
        return List<String>.from(response.data['locations']);
      }
    } catch (e) {
      print('Error al obtener ubicaciones: $e');
    }
    return [];
  }
}
