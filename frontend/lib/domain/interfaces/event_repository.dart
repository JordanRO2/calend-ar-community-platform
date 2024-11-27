// frontend/lib/domain/interfaces/event_repository.dart

import 'package:frontend/domain/entities/event.dart';

abstract class EventRepository {
  Future<Event?> getEventById(String id);
  Future<List<Event>> getAllEvents(int page, int limit);
  Future<String?> createEvent(Event event);
  Future<void> updateEvent(String id, Event event);
  Future<void> deleteEvent(String id);
  Future<void> addAttendee(String eventId, String userId);
  Future<void> removeAttendee(String eventId, String userId);
  Future<List<Event>> getFeaturedEvents(int page, int limit);
  Future<List<Event>> filterEvents(
      Map<String, dynamic> filters, int page, int limit);
  Future<void> manageRecurrence(
      String eventId, Map<String, dynamic> recurrenceData);
  Future<void> cancelEvent(String eventId);
  Future<List<String>> getCategories();
  Future<List<String>> getTypes();
  Future<List<String>> getLocations();
}
