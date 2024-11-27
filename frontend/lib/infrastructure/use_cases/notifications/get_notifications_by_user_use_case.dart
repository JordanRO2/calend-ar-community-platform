// relative path: frontend/lib/application/use_cases/notifications/get_notifications_by_user_use_case.dart

import 'package:frontend/domain/entities/notification.dart';
import 'package:frontend/domain/interfaces/notification_repository.dart';

class GetNotificationsByUserUseCase {
  final NotificationRepository notificationRepository;

  GetNotificationsByUserUseCase(this.notificationRepository);

  /// Ejecuta la obtención de todas las notificaciones de un usuario específico con paginación.
  Future<List<Notification>> execute(String userId,
      {int page = 1, int limit = 10}) async {
    try {
      return await notificationRepository.getNotificationsByUser(userId,
          page: page, limit: limit);
    } catch (e) {
      // Manejo de errores: imprime el mensaje para depuración
      print('Error al obtener las notificaciones del usuario: $e');
      rethrow; // Re-lanza la excepción para permitir el manejo en la capa de presentación si es necesario
    }
  }
}
