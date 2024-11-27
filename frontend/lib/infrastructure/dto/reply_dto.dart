class ReplyDTO {
  final String? id;
  final String user;
  final String parentComment;
  final String content;
  final int likes; // Like count as an integer
  final DateTime? createdAt;

  ReplyDTO({
    this.id,
    required this.user,
    required this.parentComment,
    required this.content,
    this.likes = 0,
    this.createdAt,
  });

  factory ReplyDTO.fromJson(Map<String, dynamic> json) {
    return ReplyDTO(
      id: json['id'] as String?,
      user: json['user'] as String,
      parentComment: json['parent_comment'] as String,
      content: json['content'] as String,
      likes: json['likes'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'parent_comment': parentComment,
      'content': content,
      'likes': likes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
