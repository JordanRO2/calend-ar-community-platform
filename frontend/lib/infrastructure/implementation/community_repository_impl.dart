import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/domain/interfaces/community_repository.dart';
import 'package:frontend/infrastructure/datasources/community_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/community_mapper.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;

  CommunityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Community?> getCommunityById(String id) async {
    try {
      final dto = await remoteDataSource.getCommunityById(id);
      return dto != null ? CommunityMapper.fromDto(dto) : null;
    } catch (e) {
      throw Exception('Error al obtener la comunidad: $e');
    }
  }

  @override
  Future<List<Community>> getAllCommunities(int page, int limit) async {
    try {
      final dtos = await remoteDataSource.getAllCommunities(page, limit);
      return dtos.map(CommunityMapper.fromDto).toList();
    } catch (e) {
      throw Exception('Error al obtener todas las comunidades: $e');
    }
  }

  @override
  Future<String?> createCommunity(Community community) async {
    try {
      final dto = CommunityMapper.toDto(community);
      return await remoteDataSource.createCommunity(dto);
    } catch (e) {
      throw Exception('Error al crear la comunidad: $e');
    }
  }

  @override
  Future<void> updateCommunity(String id, Community community) async {
    try {
      final dto = CommunityMapper.toDto(community);
      await remoteDataSource.updateCommunity(id, dto);
    } catch (e) {
      throw Exception('Error al actualizar la comunidad: $e');
    }
  }

  @override
  Future<void> deleteCommunity(String id) async {
    try {
      await remoteDataSource.deleteCommunity(id);
    } catch (e) {
      throw Exception('Error al eliminar la comunidad: $e');
    }
  }

  @override
  Future<void> addModerator(String communityId, String userId) async {
    try {
      await remoteDataSource.addModerator(communityId, userId);
    } catch (e) {
      throw Exception('Error al añadir moderador: $e');
    }
  }

  @override
  Future<void> removeModerator(String communityId, String userId) async {
    try {
      await remoteDataSource.removeModerator(communityId, userId);
    } catch (e) {
      throw Exception('Error al eliminar moderador: $e');
    }
  }

  @override
  Future<List<Community>> getFeaturedCommunities(int page, int limit) async {
    try {
      final dtos = await remoteDataSource.getFeaturedCommunities(page, limit);
      return dtos.map(CommunityMapper.fromDto).toList();
    } catch (e) {
      throw Exception('Error al obtener comunidades destacadas: $e');
    }
  }

  @override
  Future<List<Community>> filterCommunities(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      final dtos =
          await remoteDataSource.filterCommunities(filters, page, limit);
      return dtos.map(CommunityMapper.fromDto).toList();
    } catch (e) {
      throw Exception('Error al filtrar comunidades: $e');
    }
  }

  @override
  Future<List<String>> getTypes() async {
    try {
      return await remoteDataSource.getTypes();
    } catch (e) {
      throw Exception('Error al obtener tipos: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await remoteDataSource.getCategories();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  @override
  Future<List<String>> getLocations() async {
    try {
      return await remoteDataSource.getLocations();
    } catch (e) {
      throw Exception('Error al obtener ubicaciones: $e');
    }
  }
}
