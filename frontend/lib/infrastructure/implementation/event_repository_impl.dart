// relative path: frontend/lib/infrastructure/implementation/event_repository_impl.dart

import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/interfaces/event_repository.dart';
import 'package:frontend/infrastructure/datasources/event_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/event_mapper.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl(this.remoteDataSource);

  @override
  Future<Event?> getEventById(String id) async {
    try {
      final eventDto = await remoteDataSource.getEventById(id);
      if (eventDto != null) {
        return EventMapper.fromDto(eventDto);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener el evento: $e');
    }
  }

  @override
  Future<List<Event>> getAllEvents(int page, int limit) async {
    try {
      final eventDtos = await remoteDataSource.getAllEvents(page, limit);
      return eventDtos.map((dto) => EventMapper.fromDto(dto)).toList();
    } catch (e) {
      throw Exception('Error al obtener eventos: $e');
    }
  }

  @override
  Future<String?> createEvent(Event event) async {
    try {
      final eventDto = EventMapper.toDto(event);
      return await remoteDataSource.createEvent(eventDto);
    } catch (e) {
      throw Exception('Error al crear el evento: $e');
    }
  }

  @override
  Future<void> updateEvent(String id, Event event) async {
    try {
      final eventDto = EventMapper.toDto(event);
      await remoteDataSource.updateEvent(id, eventDto);
    } catch (e) {
      throw Exception('Error al actualizar el evento: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await remoteDataSource.deleteEvent(id);
    } catch (e) {
      throw Exception('Error al eliminar el evento: $e');
    }
  }

  @override
  Future<void> addAttendee(String eventId, String userId) async {
    try {
      await remoteDataSource.addAttendee(eventId, userId);
    } catch (e) {
      throw Exception('Error al añadir asistente: $e');
    }
  }

  @override
  Future<void> removeAttendee(String eventId, String userId) async {
    try {
      await remoteDataSource.removeAttendee(eventId, userId);
    } catch (e) {
      throw Exception('Error al eliminar asistente: $e');
    }
  }

  @override
  Future<List<Event>> getFeaturedEvents(int page, int limit) async {
    try {
      final eventDtos = await remoteDataSource.getFeaturedEvents(page, limit);
      return eventDtos.map((dto) => EventMapper.fromDto(dto)).toList();
    } catch (e) {
      throw Exception('Error al obtener eventos destacados: $e');
    }
  }

  @override
  Future<List<Event>> filterEvents(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      final eventDtos =
          await remoteDataSource.filterEvents(filters, page, limit);
      return eventDtos.map((dto) => EventMapper.fromDto(dto)).toList();
    } catch (e) {
      throw Exception('Error al filtrar eventos: $e');
    }
  }

  @override
  Future<void> manageRecurrence(
      String eventId, Map<String, dynamic> recurrenceData) async {
    try {
      await remoteDataSource.manageRecurrence(eventId, recurrenceData);
    } catch (e) {
      throw Exception('Error al gestionar la recurrencia del evento: $e');
    }
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    try {
      await remoteDataSource.cancelEvent(eventId);
    } catch (e) {
      throw Exception('Error al cancelar el evento: $e');
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
  Future<List<String>> getTypes() async {
    try {
      return await remoteDataSource.getTypes();
    } catch (e) {
      throw Exception('Error al obtener tipos: $e');
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
