// relative path: frontend/lib/domain/entities/notification.dart

class Notification {
  final String id;
  final String user;
  final String message;
  final String type; // Ejemplos: "evento", "comentario", "recordatorio"
  final String status; // "unread" o "read"
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.user,
    required this.message,
    required this.type,
    this.status = "unread", // Predeterminado como "unread"
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Marca la notificación como leída.
  Notification markAsRead() {
    return Notification(
      id: id,
      user: user,
      message: message,
      type: type,
      status: "read",
      createdAt: createdAt,
    );
  }

  /// Verifica si la notificación está leída.
  bool isRead() {
    return status == "read";
  }
}
