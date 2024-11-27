// frontend/lib/infrastructure/datasources/event_remote_data_source.dart

import 'package:frontend/infrastructure/dto/event_dto.dart';
import 'package:frontend/infrastructure/network/api_client.dart';

class EventRemoteDataSource {
  final ApiClient apiClient;

  EventRemoteDataSource(this.apiClient);

  // Obtener un evento por ID
  Future<EventDTO?> getEventById(String id) async {
    try {
      final response = await apiClient.get('/api/events/$id');
      if (response.statusCode == 200) {
        return EventDTO.fromJson(response.data);
      }
    } catch (e) {
      print('Error al obtener el evento: $e');
    }
    return null;
  }

  // Obtener eventos con paginación
  Future<List<EventDTO>> getAllEvents(int page, int limit) async {
    try {
      final response = await apiClient
          .get('/api/events', queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => EventDTO.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error al obtener eventos: $e');
    }
    return [];
  }

  // Crear un evento
  Future<String?> createEvent(EventDTO event) async {
    try {
      final response =
          await apiClient.post('/api/events/create', data: event.toJson());
      if (response.statusCode == 201) {
        return response.data['event_id'];
      }
    } catch (e) {
      print('Error al crear el evento: $e');
    }
    return null;
  }

  // Actualizar un evento
  Future<void> updateEvent(String id, EventDTO event) async {
    try {
      await apiClient.put('/api/events/update/$id', data: event.toJson());
    } catch (e) {
      print('Error al actualizar el evento: $e');
    }
  }

  // Eliminar un evento
  Future<void> deleteEvent(String id) async {
    try {
      await apiClient.delete('/api/events/delete/$id');
    } catch (e) {
      print('Error al eliminar el evento: $e');
    }
  }

  // Añadir un asistente a un evento
  Future<void> addAttendee(String eventId, String userId) async {
    try {
      await apiClient
          .post('/api/events/$eventId/attend', data: {'user_id': userId});
    } catch (e) {
      print('Error al añadir asistente: $e');
    }
  }

  // Eliminar un asistente de un evento
  Future<void> removeAttendee(String eventId, String userId) async {
    try {
      await apiClient
          .delete('/api/events/$eventId/attend', data: {'user_id': userId});
    } catch (e) {
      print('Error al eliminar asistente: $e');
    }
  }

  // Obtener eventos destacados con paginación
  Future<List<EventDTO>> getFeaturedEvents(int page, int limit) async {
    try {
      final response = await apiClient.get('/api/events/featured',
          queryParameters: {'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => EventDTO.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error al obtener eventos destacados: $e');
    }
    return [];
  }

  // Filtrar eventos según criterios
  Future<List<EventDTO>> filterEvents(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      final response = await apiClient.get('/api/events/filter',
          queryParameters: {...filters, 'page': page, 'limit': limit});
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => EventDTO.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error al filtrar eventos: $e');
    }
    return [];
  }

  // Gestionar la recurrencia de un evento
  Future<void> manageRecurrence(
      String eventId, Map<String, dynamic> recurrenceData) async {
    try {
      await apiClient.post('/api/events/$eventId/recurrence',
          data: recurrenceData);
    } catch (e) {
      print('Error al gestionar la recurrencia: $e');
    }
  }

  // Cancelar un evento
  Future<void> cancelEvent(String eventId) async {
    try {
      await apiClient.post('/api/events/$eventId/cancel');
    } catch (e) {
      print('Error al cancelar el evento: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await apiClient.get('/api/events/categories');
      if (response.statusCode == 200) {
        return List<String>.from(response.data['categories']);
      }
    } catch (e) {
      print('Error al obtener categorías: $e');
    }
    return [];
  }

  Future<List<String>> getTypes() async {
    try {
      final response = await apiClient.get('/api/events/types');
      if (response.statusCode == 200) {
        return List<String>.from(response.data['types']);
      }
    } catch (e) {
      print('Error al obtener tipos: $e');
    }
    return [];
  }

  Future<List<String>> getLocations() async {
    try {
      final response = await apiClient.get('/api/events/locations');
      if (response.statusCode == 200) {
        return List<String>.from(response.data['locations']);
      }
    } catch (e) {
      print('Error al obtener ubicaciones: $e');
    }
    return [];
  }
}
