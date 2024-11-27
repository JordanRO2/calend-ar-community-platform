// relative path: frontend/lib/domain/entities/comment.dart

class Comment {
  final String id;
  final String user; // ID del usuario que hizo el comentario
  final String event; // ID del evento al que pertenece el comentario
  final String content;
  int likes;
  List<Comment> replies; // Lista de respuestas al comentario
  final DateTime createdAt;
  int reportCount;

  Comment({
    required this.id,
    required this.user,
    required this.event,
    required this.content,
    this.likes = 0,
    List<Comment>? replies,
    DateTime? createdAt,
    this.reportCount = 0,
  })  : replies = replies ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Añade una respuesta al comentario.
  void addReply(Comment reply) {
    replies.add(reply);
  }

  /// Incrementa el número de likes del comentario.
  void likeComment() {
    likes++;
  }

  /// Verifica que el contenido del comentario no esté vacío.
  bool validateContent() {
    return content.isNotEmpty;
  }
}
