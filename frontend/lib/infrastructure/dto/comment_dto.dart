// relative path: frontend/lib/infrastructure/dto/comment_dto.dart

class CommentDTO {
  final String? id;
  final String user; // ID del usuario que hizo el comentario
  final String event; // ID del evento al que pertenece el comentario
  final String content;
  final int likes;
  final List<CommentDTO> replies; // Lista de respuestas al comentario
  final DateTime? createdAt;
  final int reportCount;

  CommentDTO({
    this.id,
    required this.user,
    required this.event,
    required this.content,
    this.likes = 0,
    List<CommentDTO>? replies,
    this.createdAt,
    this.reportCount = 0,
  }) : replies = replies ?? [];

  /// Crea una instancia de `CommentDTO` desde un JSON.
  factory CommentDTO.fromJson(Map<String, dynamic> json) {
    return CommentDTO(
      id: json['id'] as String?,
      user: json['user'] as String,
      event: json['event'] as String,
      content: json['content'] as String,
      likes: json['likes'] as int? ?? 0,
      replies: (json['replies'] as List<dynamic>?)
              ?.map(
                  (reply) => CommentDTO.fromJson(reply as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      reportCount: json['reportCount'] as int? ?? 0,
    );
  }

  /// Convierte una instancia de `CommentDTO` a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'event': event,
      'content': content,
      'likes': likes,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'reportCount': reportCount,
    };
  }
}
