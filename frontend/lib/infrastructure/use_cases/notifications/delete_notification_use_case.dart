// relative path: frontend/lib/application/use_cases/notifications/delete_notification_use_case.dart

import 'package:frontend/domain/interfaces/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository notificationRepository;

  DeleteNotificationUseCase(this.notificationRepository);

  /// Ejecuta la eliminación de una notificación específica por su ID.
  Future<void> execute(String notificationId) async {
    try {
      await notificationRepository.deleteNotification(notificationId);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al eliminar la notificación: $e');
      rethrow; // Re-lanza la excepción para permitir su manejo en la capa de presentación si es necesario
    }
  }
}
