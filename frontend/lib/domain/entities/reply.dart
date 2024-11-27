// relative path: frontend/lib/domain/entities/reply.dart

class Reply {
  final String? id; // Optional ID of the reply
  final String user; // ID of the user who made the reply
  final String parentComment; // ID of the comment being replied to
  final String content; // Content of the reply
  int likes; // Count of likes for the reply
  final DateTime createdAt; // Timestamp for when the reply was created

  // Constructor with optional `id` and `createdAt`, default `likes` to 0
  Reply({
    this.id,
    required this.user,
    required this.parentComment,
    required this.content,
    this.likes = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Method to check if the reply has likes
  bool hasLikes() {
    return likes > 0;
  }

  /// Increments the number of likes for the reply
  void addLike() {
    likes++;
  }

  /// Decrements the number of likes for the reply, ensuring it doesn’t go below 0
  void removeLike() {
    if (likes > 0) {
      likes--;
    }
  }
}
