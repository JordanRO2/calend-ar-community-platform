// relative path: frontend/lib/infrastructure/implementation/notification_repository_impl.dart

import 'package:frontend/domain/entities/notification.dart';
import 'package:frontend/domain/interfaces/notification_repository.dart';
import 'package:frontend/infrastructure/datasources/notification_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/notification_mapper.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  /// Crea una nueva notificación en la fuente de datos remota.
  @override
  Future<void> createNotification(Notification notification) async {
    final notificationDto = NotificationMapper.toDto(notification);
    await remoteDataSource.createNotification(notificationDto);
  }

  /// Marca una notificación como leída en la fuente de datos remota.
  @override
  Future<void> markAsRead(String notificationId) async {
    await remoteDataSource.markAsRead(notificationId);
  }

  /// Obtiene una notificación específica por su ID desde la fuente de datos remota.
  @override
  Future<Notification?> getNotificationById(String notificationId) async {
    final notificationDto =
        await remoteDataSource.getNotificationById(notificationId);
    return notificationDto != null
        ? NotificationMapper.fromDto(notificationDto)
        : null;
  }

  /// Obtiene todas las notificaciones de un usuario específico desde la fuente de datos remota.
  @override
  Future<List<Notification>> getNotificationsByUser(String userId,
      {int page = 1, int limit = 10}) async {
    final notificationDtos = await remoteDataSource
        .getNotificationsByUser(userId, page: page, limit: limit);
    return notificationDtos.map(NotificationMapper.fromDto).toList();
  }

  /// Elimina una notificación específica por su ID en la fuente de datos remota.
  @override
  Future<void> deleteNotification(String notificationId) async {
    await remoteDataSource.deleteNotification(notificationId);
  }
}
