// relative path: frontend/lib/infrastructure/datasources/notification_remote_data_source.dart

import 'package:frontend/infrastructure/network/api_client.dart';
import 'package:frontend/infrastructure/dto/notification_dto.dart';

class NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSource(this.apiClient);

  /// Crea una nueva notificación en el backend.
  Future<void> createNotification(NotificationDTO notification) async {
    try {
      await apiClient.post('/api/notifications/create',
          data: notification.toJson());
    } catch (e) {
      print('Error al crear la notificación: $e');
      rethrow;
    }
  }

  /// Marca una notificación como leída en el backend.
  Future<void> markAsRead(String notificationId) async {
    try {
      await apiClient.post('/api/notifications/$notificationId/mark-read');
    } catch (e) {
      print('Error al marcar la notificación como leída: $e');
      rethrow;
    }
  }

  /// Obtiene una notificación específica por su ID desde el backend.
  Future<NotificationDTO?> getNotificationById(String notificationId) async {
    try {
      final response =
          await apiClient.get('/api/notifications/$notificationId');
      if (response.statusCode == 200) {
        return NotificationDTO.fromJson(response.data);
      }
    } catch (e) {
      print('Error al obtener la notificación por ID: $e');
    }
    return null;
  }

  /// Obtiene todas las notificaciones de un usuario específico desde el backend, con soporte de paginación.
  Future<List<NotificationDTO>> getNotificationsByUser(String userId,
      {int page = 1, int limit = 10}) async {
    try {
      final response = await apiClient
          .get('/api/notifications/user/$userId', queryParameters: {
        'page': page,
        'limit': limit,
      });
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((data) => NotificationDTO.fromJson(data))
            .toList();
      }
    } catch (e) {
      print('Error al obtener las notificaciones del usuario: $e');
    }
    return [];
  }

  /// Elimina una notificación específica por su ID desde el backend.
  Future<void> deleteNotification(String notificationId) async {
    try {
      await apiClient.delete('/api/notifications/$notificationId/delete');
    } catch (e) {
      print('Error al eliminar la notificación: $e');
      rethrow;
    }
  }
}
