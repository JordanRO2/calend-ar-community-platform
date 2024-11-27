// relative path: frontend/lib/infrastructure/mappers/comment_mapper.dart

import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/infrastructure/dto/comment_dto.dart';

class CommentMapper {
  /// Convierte una instancia de `Comment` a `CommentDTO`.
  static CommentDTO toDto(Comment comment) {
    return CommentDTO(
      id: comment.id,
      user: comment.user,
      event: comment.event,
      content: comment.content,
      likes: comment.likes,
      replies: comment.replies.map((reply) => toDto(reply)).toList(),
      createdAt: comment.createdAt,
      reportCount: comment.reportCount,
    );
  }

  /// Convierte una instancia de `CommentDTO` a `Comment`.
  static Comment fromDto(CommentDTO commentDto) {
    return Comment(
      id: commentDto.id ?? '',
      user: commentDto.user,
      event: commentDto.event,
      content: commentDto.content,
      likes: commentDto.likes,
      replies: commentDto.replies.map((replyDto) => fromDto(replyDto)).toList(),
      createdAt: commentDto.createdAt ?? DateTime.now(),
      reportCount: commentDto.reportCount,
    );
  }
}
