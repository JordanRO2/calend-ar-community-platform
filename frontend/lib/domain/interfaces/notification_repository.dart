// relative path: frontend/lib/domain/interfaces/notification_repository.dart

import 'package:frontend/domain/entities/notification.dart';

abstract class NotificationRepository {
  /// Crea una nueva notificación.
  Future<void> createNotification(Notification notification);

  /// Marca una notificación como leída por su ID.
  Future<void> markAsRead(String notificationId);

  /// Obtiene una notificación específica por su ID.
  Future<Notification?> getNotificationById(String notificationId);

  /// Obtiene todas las notificaciones de un usuario específico con paginación.
  Future<List<Notification>> getNotificationsByUser(String userId,
      {int page = 1, int limit = 10});

  /// Elimina una notificación específica por su ID.
  Future<void> deleteNotification(String notificationId);
}
