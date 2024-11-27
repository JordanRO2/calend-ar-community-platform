import 'package:frontend/domain/entities/reply.dart';

abstract class ReplyRepository {
  Future<Reply?> getReplyById(String id);
  Future<String?> createReply(Reply reply);
  Future<void> updateReply(String id, Reply reply);
  Future<void> deleteReply(String id);
  Future<List<Reply>> getRepliesByComment(
      String commentId, int page, int limit);
  Future<void> likeReply(String replyId, String userId);
  Future<List<String>> getReplyLikes(String replyId);
}
