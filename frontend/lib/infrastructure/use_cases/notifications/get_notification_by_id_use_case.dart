// relative path: frontend/lib/application/use_cases/notifications/get_notification_by_id_use_case.dart

import 'package:frontend/domain/entities/notification.dart';
import 'package:frontend/domain/interfaces/notification_repository.dart';

class GetNotificationByIdUseCase {
  final NotificationRepository notificationRepository;

  GetNotificationByIdUseCase(this.notificationRepository);

  /// Ejecuta la obtención de una notificación específica por su ID.
  Future<Notification?> execute(String notificationId) async {
    try {
      return await notificationRepository.getNotificationById(notificationId);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al obtener la notificación por ID: $e');
      rethrow; // Re-lanza la excepción para permitir su manejo en la capa de presentación si es necesario
    }
  }
}
