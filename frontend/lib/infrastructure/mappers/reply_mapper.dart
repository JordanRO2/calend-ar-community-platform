// relative path: frontend/lib/infrastructure/mappers/reply_mapper.dart

import 'package:frontend/domain/entities/reply.dart';
import 'package:frontend/infrastructure/dto/reply_dto.dart';

class ReplyMapper {
  static ReplyDTO toDto(Reply reply) {
    return ReplyDTO(
      id: reply.id,
      user: reply.user,
      parentComment: reply.parentComment,
      content: reply.content,
      likes: reply.likes, // Both are integers now
      createdAt: reply.createdAt,
    );
  }

  static Reply fromDto(ReplyDTO dto) {
    return Reply(
      id: dto.id,
      user: dto.user,
      parentComment: dto.parentComment,
      content: dto.content,
      likes: dto.likes, // Both are integers now
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }
}
