// relative path: frontend/lib/infrastructure/datasources/calendar_remote_data_source.dart

import 'package:frontend/infrastructure/dto/calendar_dto.dart';
import 'package:frontend/infrastructure/network/api_client.dart';

class CalendarRemoteDataSource {
  final ApiClient apiClient;

  CalendarRemoteDataSource(this.apiClient);

  /// Crea un nuevo calendario.
  Future<String?> createCalendar(CalendarDTO calendar) async {
    try {
      final response = await apiClient.post('/api/calendars/create',
          data: calendar.toJson());
      if (response.statusCode == 201) {
        return response.data['calendar_id'];
      }
    } catch (e) {
      print('Error al crear el calendario: $e');
    }
    return null;
  }

  /// Actualiza un calendario existente.
  Future<bool> updateCalendar(String calendarId, CalendarDTO calendar) async {
    try {
      final response = await apiClient.put('/api/calendars/update/$calendarId',
          data: calendar.toJson());
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar el calendario: $e');
      return false;
    }
  }

  /// Elimina un calendario por ID.
  Future<bool> deleteCalendar(String calendarId) async {
    try {
      final response =
          await apiClient.delete('/api/calendars/delete/$calendarId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar el calendario: $e');
      return false;
    }
  }

  /// Obtiene un calendario por su ID.
  Future<CalendarDTO?> getCalendarById(String calendarId) async {
    try {
      final response = await apiClient.get('/api/calendars/$calendarId');
      if (response.statusCode == 200) {
        return CalendarDTO.fromJson(response.data);
      }
    } catch (e) {
      print('Error al obtener el calendario por ID: $e');
    }
    return null;
  }

  /// Obtiene todos los calendarios con paginación.
  Future<List<CalendarDTO>> getAllCalendars(int page, int limit) async {
    try {
      final response = await apiClient.get('/api/calendars',
          queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => CalendarDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener todos los calendarios: $e');
    }
    return [];
  }

  /// Añade un evento a un calendario.
  Future<bool> addEventToCalendar(String calendarId, String eventId) async {
    try {
      final response = await apiClient.post(
          '/api/calendars/$calendarId/add-event',
          data: {'event_id': eventId});
      return response.statusCode == 200;
    } catch (e) {
      print('Error al añadir el evento al calendario: $e');
      return false;
    }
  }

  /// Elimina un evento de un calendario.
  Future<bool> removeEventFromCalendar(
      String calendarId, String eventId) async {
    try {
      final response = await apiClient
          .delete('/api/calendars/$calendarId/remove-event/$eventId');
      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar el evento del calendario: $e');
      return false;
    }
  }

  /// Lista calendarios públicos con paginación.
  Future<List<CalendarDTO>> listPublicCalendars(int page, int limit) async {
    try {
      final response = await apiClient.get('/api/calendars/public',
          queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => CalendarDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al listar calendarios públicos: $e');
    }
    return [];
  }

  /// Genera una URL pública para compartir un calendario.
  Future<String?> shareCalendar(String calendarId) async {
    try {
      final response = await apiClient.post('/api/calendars/$calendarId/share');
      if (response.statusCode == 200) {
        return response.data['shared_url'];
      }
    } catch (e) {
      print('Error al compartir el calendario: $e');
    }
    return null;
  }

  /// Obtiene la lista de suscriptores de un calendario.
  Future<List<String>> getSubscribers(String calendarId) async {
    try {
      final response =
          await apiClient.get('/api/calendars/$calendarId/subscribers');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
    } catch (e) {
      print('Error al obtener los suscriptores del calendario: $e');
    }
    return [];
  }

  /// Configura un recordatorio para un evento en un calendario.
  Future<bool> setEventReminder(String calendarId, String eventId,
      Map<String, dynamic> reminderData) async {
    try {
      final response = await apiClient
          .post('/api/calendars/$calendarId/set-reminder', data: {
        'event_id': eventId,
        'reminder_data': reminderData,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Error al configurar el recordatorio para el evento: $e');
      return false;
    }
  }
}
