import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/infrastructure/use_cases/calendars/calendars_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:frontend/presentation/common/message_type.dart';

class CalendarProvider extends ChangeNotifier {
  // Use cases
  final CreateCalendarUseCase createCalendarUseCase;
  final UpdateCalendarUseCase updateCalendarUseCase;
  final DeleteCalendarUseCase deleteCalendarUseCase;
  final GetCalendarByIdUseCase getCalendarByIdUseCase;
  final GetAllCalendarsUseCase getAllCalendarsUseCase;
  final AddEventToCalendarUseCase addEventToCalendarUseCase;
  final RemoveEventFromCalendarUseCase removeEventFromCalendarUseCase;
  final ListPublicCalendarsUseCase listPublicCalendarsUseCase;
  final ShareCalendarUseCase shareCalendarUseCase;
  final GetCalendarSubscribersUseCase getCalendarSubscribersUseCase;
  final SetEventReminderUseCase setEventReminderUseCase;

  // Injected socket service
  final SocketService _socketService;

  // State variables
  List<Calendar> _calendars = [];
  Calendar? _selectedCalendar;
  String? _sharedUrl;
  List<String> _subscribers = [];
  String? _message;
  MessageType? _messageType;
  bool _isLoading = false;

  // Getters
  List<Calendar> get calendars => _calendars;
  Calendar? get selectedCalendar => _selectedCalendar;
  String? get sharedUrl => _sharedUrl;
  List<String> get subscribers => _subscribers;
  String? get message => _message;
  MessageType? get messageType => _messageType;
  bool get isLoading => _isLoading;

  CalendarProvider({
    required this.createCalendarUseCase,
    required this.updateCalendarUseCase,
    required this.deleteCalendarUseCase,
    required this.getCalendarByIdUseCase,
    required this.getAllCalendarsUseCase,
    required this.addEventToCalendarUseCase,
    required this.removeEventFromCalendarUseCase,
    required this.listPublicCalendarsUseCase,
    required this.shareCalendarUseCase,
    required this.getCalendarSubscribersUseCase,
    required this.setEventReminderUseCase,
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

  // WebSocket handlers
  void _initializeWebSocket() {
    _socketService.on('calendar_created', _handleCalendarCreated);
    _socketService.on('calendar_updated', _handleCalendarUpdated);
    _socketService.on('calendar_deleted', _handleCalendarDeleted);
    _socketService.on('event_added_to_calendar', _handleEventAddedToCalendar);
    _socketService.on(
        'event_removed_from_calendar', _handleEventRemovedFromCalendar);
    _socketService.on('calendar_shared', _handleCalendarShared);
    _socketService.on('reminder_set', _handleReminderSet);
  }

  void _handleCalendarCreated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('calendar_id')) {
      getCalendarById(data['calendar_id']).then((_) {
        getAllCalendars();
        _setMessage('Nuevo calendario creado', MessageType.success);
      });
    }
  }

  void _handleCalendarUpdated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('calendar_id')) {
      final calendarId = data['calendar_id'];

      if (_selectedCalendar?.id == calendarId) {
        getCalendarById(calendarId);
      }

      getAllCalendars();
      _setMessage('Calendario actualizado', MessageType.success);
    }
  }

  void _handleCalendarDeleted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('calendar_id')) {
      final calendarId = data['calendar_id'];

      if (_selectedCalendar?.id == calendarId) {
        _selectedCalendar = null;
      }

      _calendars.removeWhere((calendar) => calendar.id == calendarId);
      notifyListeners();
      _setMessage('Calendario eliminado', MessageType.success);
    }
  }

  void _handleEventAddedToCalendar(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('calendar_id')) {
      final calendarId = data['calendar_id'];

      if (_selectedCalendar?.id == calendarId) {
        getCalendarById(calendarId);
      }

      getAllCalendars();
      _setMessage('Evento añadido al calendario', MessageType.success);
    }
  }

  void _handleEventRemovedFromCalendar(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('calendar_id')) {
      final calendarId = data['calendar_id'];
      final eventId = data['event_id'];

      if (_selectedCalendar?.id == calendarId) {
        _selectedCalendar = _selectedCalendar?.copyWith(
          events: _selectedCalendar!.events
              .where((event) => event.id != eventId)
              .toList(),
        );
      }

      final calendarIndex = _calendars.indexWhere((c) => c.id == calendarId);
      if (calendarIndex != -1) {
        _calendars[calendarIndex] = _calendars[calendarIndex].copyWith(
          events: _calendars[calendarIndex]
              .events
              .where((event) => event.id != eventId)
              .toList(),
        );
      }

      notifyListeners();
      _setMessage('Evento eliminado del calendario', MessageType.success);
    }
  }

  void _handleCalendarShared(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('calendar_id')) {
      final calendarId = data['calendar_id'];
      _sharedUrl = data['shared_url'];

      if (_selectedCalendar?.id == calendarId) {
        getCalendarById(calendarId);
      }

      notifyListeners();
      _setMessage('Calendario compartido exitosamente', MessageType.success);
    }
  }

  void _handleReminderSet(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('calendar_id')) {
      final calendarId = data['calendar_id'];

      if (_selectedCalendar?.id == calendarId) {
        getCalendarById(calendarId);
      }
      _setMessage('Recordatorio configurado exitosamente', MessageType.success);
    }
  }

  // CRUD Methods and operations
  Future<void> createCalendar(Calendar calendar) async {
    try {
      _setLoading(true);
      final calendarId = await createCalendarUseCase.execute(calendar);
      if (calendarId != null) {
        await getAllCalendars();
        _setMessage('Calendario creado exitosamente', MessageType.success);
      } else {
        _setMessage('No se pudo crear el calendario', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al crear el calendario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCalendar(String calendarId, Calendar calendar) async {
    try {
      _setLoading(true);
      final success = await updateCalendarUseCase.execute(calendarId, calendar);
      if (success) {
        await getCalendarById(calendarId);
        _setMessage('Calendario actualizado exitosamente', MessageType.success);
      } else {
        _setMessage('No se pudo actualizar el calendario', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al actualizar el calendario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCalendar(String calendarId) async {
    try {
      _setLoading(true);
      final success = await deleteCalendarUseCase.execute(calendarId);
      if (success) {
        _calendars.removeWhere((calendar) => calendar.id == calendarId);
        if (_selectedCalendar?.id == calendarId) {
          _selectedCalendar = null;
        }
        notifyListeners();
        _setMessage('Calendario eliminado exitosamente', MessageType.success);
      } else {
        _setMessage('No se pudo eliminar el calendario', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al eliminar el calendario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getCalendarById(String calendarId) async {
    try {
      _setLoading(true);
      final calendarDto = await getCalendarByIdUseCase.execute(calendarId);
      if (calendarDto != null) {
        final events = calendarDto.events.map<Event>((eventJson) {
          return Event.fromJson(eventJson as Map<String, dynamic>);
        }).toList();

        _selectedCalendar = Calendar(
          id: calendarDto.id,
          name: calendarDto.name,
          owner: calendarDto.owner,
          events: events,
          isPublic: calendarDto.isPublic,
          sharedUrl: calendarDto.sharedUrl,
          createdAt: calendarDto.createdAt,
        );
        notifyListeners();
      } else {
        _selectedCalendar = null;
        _setMessage('Calendario no encontrado', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al obtener el calendario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addEventToCalendar(String calendarId, String eventId) async {
    try {
      _setLoading(true);
      final success =
          await addEventToCalendarUseCase.execute(calendarId, eventId);
      if (success) {
        await getCalendarById(calendarId);
        _setMessage(
            'Evento añadido exitosamente al calendario', MessageType.success);
      } else {
        _setMessage(
            'No se pudo añadir el evento al calendario', MessageType.error);
      }
    } catch (e) {
      _setMessage(
          'Error al añadir el evento al calendario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeEventFromCalendar(
      String calendarId, String eventId) async {
    try {
      _setLoading(true);
      final success =
          await removeEventFromCalendarUseCase.execute(calendarId, eventId);
      if (success) {
        await getCalendarById(calendarId);
        _setMessage('Evento eliminado exitosamente del calendario',
            MessageType.success);
      } else {
        _setMessage(
            'No se pudo eliminar el evento del calendario', MessageType.error);
      }
    } catch (e) {
      _setMessage(
          'Error al eliminar el evento del calendario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> shareCalendar(String calendarId) async {
    try {
      _setLoading(true);
      _sharedUrl = await shareCalendarUseCase.execute(calendarId);
      if (_sharedUrl != null) {
        _setMessage('Calendario compartido exitosamente', MessageType.success);
      } else {
        _setMessage('No se pudo compartir el calendario', MessageType.error);
      }
      notifyListeners();
    } catch (e) {
      _setMessage('Error al compartir el calendario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getSubscribers(String calendarId) async {
    try {
      _setLoading(true);
      _subscribers = await getCalendarSubscribersUseCase.execute(calendarId);
      notifyListeners();
    } catch (e) {
      _setMessage('Error al obtener los suscriptores: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setEventReminder(String calendarId, String eventId,
      Map<String, dynamic> reminderData) async {
    try {
      _setLoading(true);
      final success = await setEventReminderUseCase.execute(
          calendarId, eventId, reminderData);
      if (success) {
        await getCalendarById(calendarId);
        _setMessage(
            'Recordatorio configurado exitosamente', MessageType.success);
      } else {
        _setMessage('No se pudo configurar el recordatorio', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al configurar el recordatorio: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getAllCalendars() async {
    try {
      _setLoading(true);
      _calendars = await getAllCalendarsUseCase.execute();
      notifyListeners();
    } catch (e) {
      _setMessage('Error al obtener los calendarios: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    await getAllCalendars();
    if (_selectedCalendar != null) {
      await getCalendarById(_selectedCalendar!.id);
    }
  }

  @override
  void dispose() {
    _socketService.off('calendar_created');
    _socketService.off('calendar_updated');
    _socketService.off('calendar_deleted');
    _socketService.off('event_added_to_calendar');
    _socketService.off('event_removed_from_calendar');
    _socketService.off('calendar_shared');
    _socketService.off('reminder_set');
    super.dispose();
  }
}
