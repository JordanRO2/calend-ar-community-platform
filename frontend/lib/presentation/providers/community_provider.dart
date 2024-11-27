import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/infrastructure/use_cases/communities/communities_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:frontend/presentation/common/message_type.dart';

class CommunityProvider extends ChangeNotifier {
  // Use cases
  final GetCommunityDetailsUseCase getCommunityDetailsUseCase;
  final CreateCommunityUseCase createCommunityUseCase;
  final UpdateCommunityUseCase updateCommunityUseCase;
  final DeleteCommunityUseCase deleteCommunityUseCase;
  final AddModeratorUseCase addModeratorUseCase;
  final RemoveModeratorUseCase removeModeratorUseCase;
  final GetFeaturedCommunitiesUseCase getFeaturedCommunitiesUseCase;
  final FilterCommunitiesUseCase filterCommunitiesUseCase;
  final GetAllCommunitiesUseCase getAllCommunitiesUseCase;
  final GetCommunityTypesUseCase getTypesUseCase;
  final GetCommunityCategoriesUseCase getCategoriesUseCase;
  final GetCommunityLocationsUseCase getLocationsUseCase;

  // Injected socket service
  final SocketService _socketService;

  // State
  Community? _currentCommunity;
  List<Community> _communities = [];
  List<Community> _featuredCommunities = [];
  String? _message;
  MessageType? _messageType;
  bool _isLoading = false;

  // Getters
  Community? get currentCommunity => _currentCommunity;
  List<Community> get communities => _communities;
  List<Community> get featuredCommunities => _featuredCommunities;
  String? get message => _message;
  MessageType? get messageType => _messageType;
  bool get isLoading => _isLoading;

  CommunityProvider({
    required this.getCommunityDetailsUseCase,
    required this.createCommunityUseCase,
    required this.updateCommunityUseCase,
    required this.deleteCommunityUseCase,
    required this.addModeratorUseCase,
    required this.removeModeratorUseCase,
    required this.getFeaturedCommunitiesUseCase,
    required this.filterCommunitiesUseCase,
    required this.getAllCommunitiesUseCase,
    required this.getTypesUseCase,
    required this.getCategoriesUseCase,
    required this.getLocationsUseCase,
    required SocketService socketService,
  }) : _socketService = socketService {
    _initializeWebSocket();
  }

  // Utility methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage(String message, MessageType type) {
    _message = message;
    _messageType = type;
    notifyListeners();
  }

  void clearMessage() {
    _message = null;
    _messageType = null;
    notifyListeners();
  }

  // WebSocket initialization and handlers
  void _initializeWebSocket() {
    _socketService.on('community_created', _handleCommunityCreated);
    _socketService.on('community_updated', _handleCommunityUpdated);
    _socketService.on('community_deleted', _handleCommunityDeleted);
    _socketService.on('moderator_added', _handleModeratorAdded);
    _socketService.on('moderator_removed', _handleModeratorRemoved);
  }

  void _handleCommunityCreated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('community_id')) {
      fetchAllCommunities(1, 10); // Update community list
      _setMessage('Nueva comunidad creada', MessageType.success);
    }
  }

  void _handleCommunityUpdated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('community_id')) {
      final communityId = data['community_id'];

      // Update if it's the current community
      if (_currentCommunity?.id == communityId) {
        fetchCommunityDetails(communityId);
      }

      // Update lists
      fetchAllCommunities(1, 10);
      fetchFeaturedCommunities(1, 10);

      _setMessage('Comunidad actualizada', MessageType.success);
    }
  }

  void _handleCommunityDeleted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('community_id')) {
      final communityId = data['community_id'];

      // Clear current community if it's the one deleted
      if (_currentCommunity?.id == communityId) {
        _currentCommunity = null;
      }

      // Remove from lists
      _communities.removeWhere((c) => c.id == communityId);
      _featuredCommunities.removeWhere((c) => c.id == communityId);

      notifyListeners();
      _setMessage('Comunidad eliminada', MessageType.success);
    }
  }

  void _handleModeratorAdded(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('community_id') &&
        data.containsKey('user_id')) {
      final communityId = data['community_id'];
      final userId = data['user_id'];

      // Update current community if applicable
      if (_currentCommunity?.id == communityId) {
        _currentCommunity!.addModerator(userId);
        notifyListeners();
      }

      _setMessage('Moderador añadido exitosamente', MessageType.success);
    }
  }

  void _handleModeratorRemoved(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('community_id') &&
        data.containsKey('user_id')) {
      final communityId = data['community_id'];
      final userId = data['user_id'];

      // Update current community if applicable
      if (_currentCommunity?.id == communityId) {
        _currentCommunity!.removeModerator(userId);
        notifyListeners();
      }

      _setMessage('Moderador removido exitosamente', MessageType.success);
    }
  }

  // CRUD Methods and operations
  Future<void> fetchCommunityDetails(String communityId) async {
    try {
      _setLoading(true);

      _currentCommunity = await getCommunityDetailsUseCase.execute(communityId);
      if (_currentCommunity == null) {
        _setMessage('No se pudo encontrar la comunidad', MessageType.error);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage(
          'Error al obtener detalles de la comunidad: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createCommunity(Community community) async {
    try {
      _setLoading(true);

      final newCommunityId = await createCommunityUseCase.execute(community);
      if (newCommunityId.isNotEmpty) {
        await fetchCommunityDetails(newCommunityId);
        _setMessage('Comunidad creada exitosamente', MessageType.success);
      } else {
        _setMessage('No se pudo crear la comunidad', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al crear comunidad: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCommunity(String id, Community community) async {
    try {
      _setLoading(true);

      await updateCommunityUseCase.execute(id, community);
      await fetchCommunityDetails(id);
      _setMessage('Comunidad actualizada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al actualizar comunidad: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCommunity(String id) async {
    try {
      _setLoading(true);

      await deleteCommunityUseCase.execute(id);
      _communities.removeWhere((community) => community.id == id);
      _featuredCommunities.removeWhere((community) => community.id == id);

      if (_currentCommunity?.id == id) {
        _currentCommunity = null;
      }

      notifyListeners();
      _setMessage('Comunidad eliminada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al eliminar comunidad: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> filterCommunities(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      _setLoading(true);

      _communities =
          await filterCommunitiesUseCase.execute(filters, page, limit);

      if (_communities.isEmpty && page == 1) {
        _setMessage(
            'No se encontraron comunidades con los filtros especificados',
            MessageType.success);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al filtrar comunidades: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addModerator(String communityId, String userId) async {
    try {
      _setLoading(true);

      await addModeratorUseCase.execute(communityId, userId);

      if (_currentCommunity?.id == communityId) {
        _currentCommunity!.addModerator(userId);
        _setMessage('Moderador añadido exitosamente', MessageType.success);
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al añadir moderador: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeModerator(String communityId, String userId) async {
    try {
      _setLoading(true);

      await removeModeratorUseCase.execute(communityId, userId);

      if (_currentCommunity?.id == communityId) {
        _currentCommunity!.removeModerator(userId);
        _setMessage('Moderador removido exitosamente', MessageType.success);
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al eliminar moderador: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchFeaturedCommunities(int page, int limit) async {
    try {
      _setLoading(true);

      _featuredCommunities =
          await getFeaturedCommunitiesUseCase.execute(page, limit);

      if (_featuredCommunities.isEmpty && page == 1) {
        _setMessage(
            'No hay comunidades destacadas disponibles', MessageType.success);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage(
          'Error al obtener comunidades destacadas: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAllCommunities(int page, int limit) async {
    try {
      _setLoading(true);

      _communities = await getAllCommunitiesUseCase.execute(page, limit);

      if (_communities.isEmpty && page == 1) {
        _setMessage('No hay comunidades disponibles', MessageType.success);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage(
          'Error al obtener todas las comunidades: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> getTypes() async {
    try {
      _setLoading(true);
      final types = await getTypesUseCase.execute();
      return types;
    } catch (e) {
      _setMessage('Error al obtener tipos: $e', MessageType.error);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> getCategories() async {
    try {
      _setLoading(true);
      final categories = await getCategoriesUseCase.execute();
      return categories;
    } catch (e) {
      _setMessage('Error al obtener categorías: $e', MessageType.error);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> getLocations() async {
    try {
      _setLoading(true);
      final locations = await getLocationsUseCase.execute();
      return locations;
    } catch (e) {
      _setMessage('Error al obtener ubicaciones: $e', MessageType.error);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    if (_currentCommunity != null) {
      await fetchCommunityDetails(_currentCommunity!.id);
    }
    await Future.wait([
      fetchAllCommunities(1, 10),
      fetchFeaturedCommunities(1, 10),
    ]);
  }

  @override
  void dispose() {
    _socketService.off('community_created');
    _socketService.off('community_updated');
    _socketService.off('community_deleted');
    _socketService.off('moderator_added');
    _socketService.off('moderator_removed');
    super.dispose();
  }
}
