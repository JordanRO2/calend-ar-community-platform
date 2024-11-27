// relative path: frontend/lib/infrastructure/mappers/notification_mapper.dart

import 'package:frontend/domain/entities/notification.dart';
import 'package:frontend/infrastructure/dto/notification_dto.dart';

class NotificationMapper {
  /// Convierte de Notification (dominio) a NotificationDTO (infraestructura).
  static NotificationDTO toDto(Notification notification) {
    return NotificationDTO(
      id: notification.id,
      user: notification.user,
      message: notification.message,
      type: notification.type,
      status: notification.status,
      createdAt: notification.createdAt,
    );
  }

  /// Convierte de NotificationDTO (infraestructura) a Notification (dominio).
  static Notification fromDto(NotificationDTO dto) {
    return Notification(
      id: dto.id ?? '',
      user: dto.user,
      message: dto.message,
      type: dto.type,
      status: dto.status,
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }
}
