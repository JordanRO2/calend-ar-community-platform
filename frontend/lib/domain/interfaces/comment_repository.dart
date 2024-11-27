import 'package:frontend/domain/entities/comment.dart';

abstract class CommentRepository {
  Future<Comment?> getCommentById(String id);
  Future<String?> createComment(Comment comment);
  Future<void> updateComment(String id, Comment comment);
  Future<void> deleteComment(String id);
  Future<List<Comment>> getCommentsByEvent(String eventId, int page, int limit);
  Future<void> likeComment(String commentId, String userId);
  Future<List<String>> getCommentLikes(String commentId);
  Future<void> reportComment(String commentId, Map<String, dynamic> reportData);
  Future<List<Comment>> getReportedComments(int page, int limit);
}
