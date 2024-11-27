// relative path: frontend/lib/infrastructure/implementation/calendar_repository_impl.dart

import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/interfaces/calendar_repository.dart';
import 'package:frontend/infrastructure/datasources/calendar_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/calendar_mapper.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource remoteDataSource;

  CalendarRepositoryImpl(this.remoteDataSource);

  @override
  Future<String?> createCalendar(Calendar calendar) async {
    try {
      final calendarDto = CalendarMapper.toDto(calendar);
      return await remoteDataSource.createCalendar(calendarDto);
    } catch (e) {
      throw Exception('Error al crear el calendario: $e');
    }
  }

  @override
  Future<bool> updateCalendar(String calendarId, Calendar calendar) async {
    try {
      final calendarDto = CalendarMapper.toDto(calendar);
      await remoteDataSource.updateCalendar(calendarId, calendarDto);
      return true;
    } catch (e) {
      throw Exception('Error al actualizar el calendario: $e');
    }
  }

  @override
  Future<bool> deleteCalendar(String calendarId) async {
    try {
      await remoteDataSource.deleteCalendar(calendarId);
      return true;
    } catch (e) {
      throw Exception('Error al eliminar el calendario: $e');
    }
  }

  @override
  Future<Calendar?> getCalendarById(String calendarId) async {
    try {
      final calendarDto = await remoteDataSource.getCalendarById(calendarId);
      return calendarDto != null ? CalendarMapper.fromDto(calendarDto) : null;
    } catch (e) {
      throw Exception('Error al obtener el calendario: $e');
    }
  }

  @override
  Future<List<Calendar>> getAllCalendars({int page = 1, int limit = 10}) async {
    try {
      final calendarDtos = await remoteDataSource.getAllCalendars(page, limit);
      return calendarDtos.map(CalendarMapper.fromDto).toList();
    } catch (e) {
      throw Exception('Error al obtener todos los calendarios: $e');
    }
  }

  @override
  Future<bool> addEventToCalendar(String calendarId, String eventId) async {
    try {
      await remoteDataSource.addEventToCalendar(calendarId, eventId);
      return true;
    } catch (e) {
      throw Exception('Error al añadir el evento al calendario: $e');
    }
  }

  @override
  Future<bool> removeEventFromCalendar(
      String calendarId, String eventId) async {
    try {
      await remoteDataSource.removeEventFromCalendar(calendarId, eventId);
      return true;
    } catch (e) {
      throw Exception('Error al eliminar el evento del calendario: $e');
    }
  }

  @override
  Future<List<Calendar>> listPublicCalendars(
      {int page = 1, int limit = 10}) async {
    try {
      final calendarDtos =
          await remoteDataSource.listPublicCalendars(page, limit);
      return calendarDtos.map(CalendarMapper.fromDto).toList();
    } catch (e) {
      throw Exception('Error al listar calendarios públicos: $e');
    }
  }

  @override
  Future<String?> shareCalendar(String calendarId) async {
    try {
      return await remoteDataSource.shareCalendar(calendarId);
    } catch (e) {
      throw Exception('Error al compartir el calendario: $e');
    }
  }

  @override
  Future<List<String>> getSubscribers(String calendarId) async {
    try {
      return await remoteDataSource.getSubscribers(calendarId);
    } catch (e) {
      throw Exception('Error al obtener los suscriptores del calendario: $e');
    }
  }

  @override
  Future<bool> setEventReminder(String calendarId, String eventId,
      Map<String, dynamic> reminderData) async {
    try {
      await remoteDataSource.setEventReminder(
          calendarId, eventId, reminderData);
      return true;
    } catch (e) {
      throw Exception('Error al configurar el recordatorio del evento: $e');
    }
  }
}
