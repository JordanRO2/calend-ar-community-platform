import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/infrastructure/use_cases/events/events_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:frontend/presentation/common/message_type.dart';

class EventProvider extends ChangeNotifier {
  // Use cases
  final GetEventDetailsUseCase getEventDetailsUseCase;
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;
  final AddAttendeeUseCase addAttendeeUseCase;
  final RemoveAttendeeUseCase removeAttendeeUseCase;
  final GetFeaturedEventsUseCase getFeaturedEventsUseCase;
  final FilterEventsUseCase filterEventsUseCase;
  final ManageRecurrenceUseCase manageRecurrenceUseCase;
  final CancelEventUseCase cancelEventUseCase;
  final GetEventCategoriesUseCase getEventCategoriesUseCase;
  final GetEventTypesUseCase getEventTypesUseCase;
  final GetEventLocationsUseCase getEventLocationsUseCase;

  // Dependency injection
  final SocketService _socketService;

  // State
  Event? _currentEvent;
  List<Event> _events = [];
  List<Event> _featuredEvents = [];
  final List<String> _eventAttendees = [];
  String? _message;
  MessageType? _messageType;
  bool _isLoading = false;

  // Getters
  Event? get currentEvent => _currentEvent;
  List<Event> get events => _events;
  List<Event> get featuredEvents => _featuredEvents;
  List<String> get eventAttendees => _eventAttendees;
  String? get message => _message;
  MessageType? get messageType => _messageType;
  bool get isLoading => _isLoading;

  // Constructor with dependency injection
  EventProvider({
    required this.getEventDetailsUseCase,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.addAttendeeUseCase,
    required this.removeAttendeeUseCase,
    required this.getFeaturedEventsUseCase,
    required this.filterEventsUseCase,
    required this.manageRecurrenceUseCase,
    required this.cancelEventUseCase,
    required this.getEventCategoriesUseCase,
    required this.getEventTypesUseCase,
    required this.getEventLocationsUseCase,
    required SocketService socketService,
  }) : _socketService = socketService {
    _initializeWebSocket();
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // State modification methods
  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotifyListeners();
  }

  void _setMessage(String message, MessageType type) {
    _message = message;
    _messageType = type;
    _safeNotifyListeners();
  }

  void clearMessage() {
    _message = null;
    _messageType = null;
    _safeNotifyListeners();
  }

  // Initialize WebSocket listeners
  void _initializeWebSocket() {
    _socketService.on('event_created', _handleEventCreated);
    _socketService.on('event_updated', _handleEventUpdated);
    _socketService.on('event_deleted', _handleEventDeleted);
    _socketService.on('attendee_added', _handleAttendeeAdded);
    _socketService.on('attendee_removed', _handleAttendeeRemoved);
    _socketService.on('event_featured', _handleEventFeatured);
    _socketService.on('event_recurrence_updated', _handleRecurrenceUpdated);
    _socketService.on('event_cancelled', _handleEventCancelled);
  }

  // Socket event handlers
  void _handleEventCreated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('event_id')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchEventDetails(data['event_id']);
        filterEvents({}, 1, 10); // Update event list
        _setMessage('Nuevo evento creado', MessageType.success);
      });
    }
  }

  void _handleEventUpdated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('event_id')) {
      final eventId = data['event_id'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEvent?.id == eventId) {
          fetchEventDetails(eventId);
        }
        filterEvents({}, 1, 10); // Update event list
        _setMessage('Evento actualizado', MessageType.success);
      });
    }
  }

  void _handleEventDeleted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('event_id')) {
      final eventId = data['event_id'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEvent?.id == eventId) {
          _currentEvent = null;
        }
        _events.removeWhere((event) => event.id == eventId);
        _featuredEvents.removeWhere((event) => event.id == eventId);
        _safeNotifyListeners();
        _setMessage('Evento eliminado', MessageType.success);
      });
    }
  }

  void _handleAttendeeAdded(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('event_id') &&
        data.containsKey('user_id')) {
      final eventId = data['event_id'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEvent?.id == eventId) {
          fetchEventDetails(eventId);
        }
        _setMessage('Asistente agregado al evento', MessageType.success);
      });
    }
  }

  void _handleAttendeeRemoved(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('event_id') &&
        data.containsKey('user_id')) {
      final eventId = data['event_id'];
      final userId = data['user_id'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEvent?.id == eventId) {
          _eventAttendees.remove(userId);
          fetchEventDetails(eventId);
        }
        _setMessage('Asistente eliminado del evento', MessageType.success);
      });
    }
  }

  void _handleEventFeatured(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('event_id')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchFeaturedEvents(1, 10); // Update featured events
        _setMessage('Evento marcado como destacado', MessageType.success);
      });
    }
  }

  void _handleRecurrenceUpdated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('event_id')) {
      final eventId = data['event_id'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEvent?.id == eventId) {
          fetchEventDetails(eventId);
        }
        _setMessage('Recurrencia del evento actualizada', MessageType.success);
      });
    }
  }

  void _handleEventCancelled(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('event_id')) {
      final eventId = data['event_id'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentEvent?.id == eventId) {
          fetchEventDetails(eventId);
        }
        _setMessage('Evento cancelado', MessageType.success);
      });
    }
  }

  // CRUD Operations
  Future<void> createEvent(Event event) async {
    try {
      _setLoading(true);
      final eventId = await createEventUseCase.execute(event);
      if (eventId != null) {
        await fetchEventDetails(eventId);
        _setMessage('Evento creado exitosamente', MessageType.success);
      } else {
        _setMessage('No se pudo crear el evento', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al crear evento: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchEventDetails(String eventId) async {
    try {
      _setLoading(true);
      _currentEvent = await getEventDetailsUseCase.execute(eventId);
      if (_currentEvent == null) {
        _setMessage('Evento no encontrado', MessageType.error);
      }
    } catch (e) {
      _setMessage(
          'Error al obtener detalles del evento: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEvent(String id, Event event) async {
    try {
      _setLoading(true);
      await updateEventUseCase.execute(id, event);
      await fetchEventDetails(id);
      _setMessage('Evento actualizado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al actualizar evento: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      _setLoading(true);
      await deleteEventUseCase.execute(id);
      _currentEvent = null;
      _events.removeWhere((event) => event.id == id);
      _featuredEvents.removeWhere((event) => event.id == id);
      _setMessage('Evento eliminado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al eliminar evento: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  // Attendee Operations
  Future<void> addAttendee(String eventId, String userId) async {
    try {
      _setLoading(true);
      await addAttendeeUseCase.execute(eventId, userId);
      await fetchEventDetails(eventId);
      _setMessage('Asistente agregado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al agregar asistente: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeAttendee(String eventId, String userId) async {
    try {
      _setLoading(true);
      await removeAttendeeUseCase.execute(eventId, userId);
      await fetchEventDetails(eventId);
      _setMessage('Asistente eliminado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al eliminar asistente: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  // Event Listing and Filtering
  Future<void> fetchFeaturedEvents(int page, int limit) async {
    try {
      _setLoading(true);
      _featuredEvents = await getFeaturedEventsUseCase.execute(page, limit);
      if (_featuredEvents.isEmpty && page == 1) {
        _setMessage(
            'No hay eventos destacados disponibles', MessageType.success);
      }
    } catch (e) {
      _setMessage('Error al obtener eventos destacados: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> filterEvents(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      _setLoading(true);
      _events = await filterEventsUseCase.execute(filters, page, limit);
      if (_events.isEmpty && page == 1) {
        _setMessage('No se encontraron eventos', MessageType.success);
      }
    } catch (e) {
      _setMessage('Error al filtrar eventos: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  // Event Management
  Future<void> manageRecurrence(
      String eventId, Map<String, dynamic> recurrenceData) async {
    try {
      _setLoading(true);
      await manageRecurrenceUseCase.execute(eventId, recurrenceData);
      await fetchEventDetails(eventId);
      _setMessage('Recurrencia actualizada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al gestionar la recurrencia: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelEvent(String eventId) async {
    try {
      _setLoading(true);
      await cancelEventUseCase.execute(eventId);
      await fetchEventDetails(eventId);
      _setMessage('Evento cancelado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al cancelar el evento: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  // Methods to get categories, types, and locations
  Future<List<String>> getCategories() async {
    try {
      _setLoading(true);
      final categories = await getEventCategoriesUseCase.execute();
      return categories;
    } catch (e) {
      _setMessage('Error al obtener categorías: $e', MessageType.error);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> getTypes() async {
    try {
      _setLoading(true);
      final types = await getEventTypesUseCase.execute();
      return types;
    } catch (e) {
      _setMessage('Error al obtener tipos: $e', MessageType.error);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> getLocations() async {
    try {
      _setLoading(true);
      final locations = await getEventLocationsUseCase.execute();
      return locations;
    } catch (e) {
      _setMessage('Error al obtener ubicaciones: $e', MessageType.error);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _socketService.off('event_created');
    _socketService.off('event_updated');
    _socketService.off('event_deleted');
    _socketService.off('attendee_added');
    _socketService.off('attendee_removed');
    _socketService.off('event_featured');
    _socketService.off('event_recurrence_updated');
    _socketService.off('event_cancelled');
    super.dispose();
  }
}
