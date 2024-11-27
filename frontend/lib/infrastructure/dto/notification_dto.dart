// relative path: frontend/lib/infrastructure/dto/notification_dto.dart

class NotificationDTO {
  final String? id;
  final String user;
  final String message;
  final String type;
  final String status;
  final DateTime? createdAt;

  NotificationDTO({
    this.id,
    required this.user,
    required this.message,
    required this.type,
    this.status = "unread",
    this.createdAt,
  });

  /// Crea una instancia de NotificationDTO a partir de un JSON.
  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      id: json['id'],
      user: json['user'],
      message: json['message'],
      type: json['type'],
      status: json['status'] ?? 'unread',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Serializa la instancia de NotificationDTO a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'message': message,
      'type': type,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
