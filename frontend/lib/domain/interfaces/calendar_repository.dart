import 'package:frontend/domain/entities/calendar.dart';

abstract class CalendarRepository {
  Future<String?> createCalendar(Calendar calendar);
  Future<bool> updateCalendar(String calendarId, Calendar calendar);
  Future<bool> deleteCalendar(String calendarId);
  Future<Calendar?> getCalendarById(String calendarId);
  Future<List<Calendar>> getAllCalendars({int page = 1, int limit = 10});
  Future<bool> addEventToCalendar(String calendarId, String eventId);
  Future<bool> removeEventFromCalendar(String calendarId, String eventId);
  Future<List<Calendar>> listPublicCalendars({int page = 1, int limit = 10});
  Future<String?> shareCalendar(String calendarId);
  Future<List<String>> getSubscribers(String calendarId);
  Future<bool> setEventReminder(
      String calendarId, String eventId, Map<String, dynamic> reminderData);
}
