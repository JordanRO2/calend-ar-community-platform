// relative path: frontend/lib/application/use_cases/notifications/create_notification_use_case.dart

import 'package:frontend/domain/entities/notification.dart';
import 'package:frontend/domain/interfaces/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationRepository notificationRepository;

  CreateNotificationUseCase(this.notificationRepository);

  /// Ejecuta la creación de una nueva notificación.
  Future<void> execute(Notification notification) async {
    try {
      await notificationRepository.createNotification(notification);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al crear la notificación: $e');
      rethrow; // Re-lanza la excepción para manejarla en la capa de presentación si es necesario
    }
  }
}
