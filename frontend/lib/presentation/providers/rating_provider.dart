// lib/presentation/providers/rating_provider.dart

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/rating.dart';
import 'package:frontend/infrastructure/use_cases/ratings/ratings_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:frontend/presentation/common/message_type.dart';

class RatingProvider extends ChangeNotifier {
  final CreateRatingUseCase createRatingUseCase;
  final UpdateRatingUseCase updateRatingUseCase;
  final DeleteRatingUseCase deleteRatingUseCase;
  final GetRatingByIdUseCase getRatingByIdUseCase;
  final GetRatingsByEventUseCase getRatingsByEventUseCase;
  final CalculateAverageRatingUseCase calculateAverageRatingUseCase;

  final SocketService _socketService;

  List<Rating> _ratings = [];
  Rating? _selectedRating;
  double _averageRating = 0.0;
  String? _message;
  MessageType? _messageType;
  bool _isLoading = false;
  String? _currentEventId;
  Map<String, List<String>> _replyLikes = {};

  List<Rating> get ratings => _ratings;
  Rating? get selectedRating => _selectedRating;
  double get averageRating => _averageRating;
  String? get message => _message;
  MessageType? get messageType => _messageType;
  bool get isLoading => _isLoading;
  Map<String, List<String>> get replyLikes => _replyLikes;

  RatingProvider({
    required this.createRatingUseCase,
    required this.updateRatingUseCase,
    required this.deleteRatingUseCase,
    required this.getRatingByIdUseCase,
    required this.getRatingsByEventUseCase,
    required this.calculateAverageRatingUseCase,
    required SocketService socketService,
  }) : _socketService = socketService {
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _socketService.on('new_rating', _handleNewRating);
    _socketService.on('rating_deleted', _handleRatingDeleted);
  }

  void _handleNewRating(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('event_id') &&
        data.containsKey('rating_id')) {
      final eventId = data['event_id'];

      if (_currentEventId == eventId) {
        fetchRatingsByEvent(eventId);
        fetchAverageRating(eventId);
      }

      _setMessage('Nueva calificación registrada', MessageType.success);
    }
  }

  void _handleRatingDeleted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('rating_id')) {
      final ratingId = data['rating_id'];

      if (_selectedRating?.id == ratingId) {
        _selectedRating = null;
      }

      _ratings.removeWhere((rating) => rating.id == ratingId);

      _replyLikes.remove(ratingId);

      if (_currentEventId != null) {
        fetchAverageRating(_currentEventId!);
      }

      notifyListeners();
      _setMessage('Calificación eliminada', MessageType.success);
    }
  }

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

  Future<void> createRating(Rating rating) async {
    try {
      _setLoading(true);
      await createRatingUseCase.execute(rating);
      _currentEventId = rating.event;

      await Future.wait([
        fetchRatingsByEvent(rating.event),
        fetchAverageRating(rating.event),
      ]);

      _setMessage('Calificación creada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al crear la calificación: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRating(String ratingId, Rating rating) async {
    try {
      _setLoading(true);
      await updateRatingUseCase.execute(ratingId, rating);
      _currentEventId = rating.event;

      await Future.wait([
        fetchRatingsByEvent(rating.event),
        fetchAverageRating(rating.event),
      ]);

      _setMessage('Calificación actualizada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al actualizar la calificación: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteRating(String ratingId) async {
    try {
      _setLoading(true);
      await deleteRatingUseCase.execute(ratingId);

      if (_selectedRating?.id == ratingId) {
        _selectedRating = null;
      }

      _ratings.removeWhere((rating) => rating.id == ratingId);

      _replyLikes.remove(ratingId);

      if (_currentEventId != null) {
        await fetchAverageRating(_currentEventId!);
      }

      notifyListeners();
      _setMessage('Calificación eliminada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al eliminar la calificación: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRatingById(String ratingId) async {
    try {
      _setLoading(true);
      _selectedRating = await getRatingByIdUseCase.execute(ratingId);
      if (_selectedRating == null) {
        _setMessage('Calificación no encontrada', MessageType.error);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al obtener la calificación: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRatingsByEvent(String eventId,
      {int page = 1, int limit = 10}) async {
    try {
      _setLoading(true);
      _currentEventId = eventId;
      _ratings = await getRatingsByEventUseCase.execute(eventId,
          page: page, limit: limit);
      if (_ratings.isEmpty && page == 1) {
        _setMessage('No hay calificaciones para mostrar', MessageType.success);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al obtener las calificaciones: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAverageRating(String eventId) async {
    try {
      _setLoading(true);
      _averageRating = await calculateAverageRatingUseCase.execute(eventId);
      notifyListeners();
    } catch (e) {
      _setMessage(
          'Error al calcular la calificación promedio: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  void selectRating(Rating? rating) {
    _selectedRating = rating;
    notifyListeners();
  }

  void clearRatings() {
    _ratings = [];
    _selectedRating = null;
    _currentEventId = null;
    _replyLikes = {};
    _averageRating = 0.0;
    notifyListeners();
  }

  void clearAllMessages() {
    _message = null;
    _messageType = null;
    notifyListeners();
  }

  Future<void> refreshData() async {
    if (_currentEventId != null) {
      await Future.wait([
        fetchRatingsByEvent(_currentEventId!, page: 1, limit: 10),
        fetchAverageRating(_currentEventId!),
      ]);
    }
  }

  void resetProvider() {
    clearRatings();
    clearAllMessages();
  }

  void resetState() {
    _isLoading = false;
    _message = null;
    _messageType = null;
    notifyListeners();
  }

  void reset() {
    resetProvider();
    resetState();
  }

  void updateProvider() {
    notifyListeners();
  }

  void handleGlobalError(String error) {
    _setMessage(error, MessageType.error);
  }

  void handleGlobalSuccess(String message) {
    _setMessage(message, MessageType.success);
  }

  void clearAll() {
    _ratings = [];
    _selectedRating = null;
    _averageRating = 0.0;
    _message = null;
    _messageType = null;
    _isLoading = false;
    _currentEventId = null;
    _replyLikes = {};
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.off('new_rating');
    _socketService.off('rating_deleted');
    super.dispose();
  }
}
