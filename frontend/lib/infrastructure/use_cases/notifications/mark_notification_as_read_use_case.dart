// relative path: frontend/lib/application/use_cases/notifications/mark_notification_as_read_use_case.dart

import 'package:frontend/domain/interfaces/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository notificationRepository;

  MarkNotificationAsReadUseCase(this.notificationRepository);

  /// Ejecuta el marcado de una notificación como leída.
  Future<void> execute(String notificationId) async {
    try {
      await notificationRepository.markAsRead(notificationId);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al marcar la notificación como leída: $e');
      rethrow; // Re-lanza la excepción para permitir el manejo en la capa de presentación si es necesario
    }
  }
}
