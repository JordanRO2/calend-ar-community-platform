import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/comment.dart';
import 'package:frontend/infrastructure/use_cases/comments/comments_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:frontend/presentation/common/message_type.dart';

class CommentProvider extends ChangeNotifier {
  // Use cases
  final GetCommentDetailsUseCase getCommentDetailsUseCase;
  final CreateCommentUseCase createCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final GetCommentsByEventUseCase getCommentsByEventUseCase;
  final LikeCommentUseCase likeCommentUseCase;
  final GetCommentLikesUseCase getCommentLikesUseCase;
  final ReportCommentUseCase reportCommentUseCase;

  // Injected socket service
  final SocketService _socketService;

  // State
  Comment? _currentComment;
  List<Comment> _comments = [];
  List<String> _commentLikes = [];
  String? _message;
  MessageType? _messageType;
  bool _isLoading = false;
  String? _currentEventId;

  // Getters
  Comment? get currentComment => _currentComment;
  List<Comment> get comments => _comments;
  List<String> get commentLikes => _commentLikes;
  String? get message => _message;
  MessageType? get messageType => _messageType;
  bool get isLoading => _isLoading;

  CommentProvider({
    required this.getCommentDetailsUseCase,
    required this.createCommentUseCase,
    required this.updateCommentUseCase,
    required this.deleteCommentUseCase,
    required this.getCommentsByEventUseCase,
    required this.likeCommentUseCase,
    required this.getCommentLikesUseCase,
    required this.reportCommentUseCase,
    required SocketService socketService,
  }) : _socketService = socketService {
    _initializeWebSocket();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setMessage(String message, MessageType type) {
    _message = message;
    _messageType = type;
    notifyListeners();
  }

  void clearMessage() {
    _message = null;
    _messageType = null;
    notifyListeners();
  }

  // WebSocket handlers
  void _initializeWebSocket() {
    _socketService.on('new_comment', _handleNewComment);
    _socketService.on('comment_updated', _handleCommentUpdated);
    _socketService.on('comment_deleted', _handleCommentDeleted);
    _socketService.on('comment_liked', _handleCommentLiked);
    _socketService.on('comment_reported', _handleCommentReported);
  }

  void _handleNewComment(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('event_id') &&
        data.containsKey('comment')) {
      final eventId = data['event_id'];

      // Update only if we're viewing comments for this event
      if (_currentEventId == eventId) {
        fetchCommentsByEvent(eventId, 1, 10);
        _setMessage('Nuevo comentario agregado', MessageType.success);
      }
    }
  }

  void _handleCommentUpdated(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('comment_id')) {
      final commentId = data['comment_id'];

      // Update the comment if it's the current one
      if (_currentComment?.id == commentId) {
        fetchCommentDetails(commentId);
      }

      // Update the comment in the list if it exists
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        fetchCommentsByEvent(_currentEventId!, 1, 10);
      }

      _setMessage('Comentario actualizado', MessageType.success);
    }
  }

  void _handleCommentDeleted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('comment_id')) {
      final commentId = data['comment_id'];

      // Clear the current comment if it's the one deleted
      if (_currentComment?.id == commentId) {
        _currentComment = null;
      }

      // Remove from the list of comments
      _comments.removeWhere((comment) => comment.id == commentId);
      notifyListeners();

      _setMessage('Comentario eliminado', MessageType.success);
    }
  }

  void _handleCommentLiked(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('comment_id') &&
        data.containsKey('user_id')) {
      final commentId = data['comment_id'];

      // Update likes if it's the current comment
      if (_currentComment?.id == commentId) {
        fetchCommentLikes(commentId);
      }

      // Update likes in the comments list
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index].likeComment();
        notifyListeners();
      }
    }
  }

  void _handleCommentReported(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('comment_id')) {
      final commentId = data['comment_id'];
      _setMessage('Comentario reportado exitosamente', MessageType.success);

      // Update the reported comment if necessary
      if (_currentComment?.id == commentId ||
          _comments.any((c) => c.id == commentId)) {
        fetchCommentsByEvent(_currentEventId!, 1, 10);
      }
    }
  }

  // CRUD Methods and operations
  Future<void> fetchCommentDetails(String commentId) async {
    try {
      _setLoading(true);
      _currentComment = await getCommentDetailsUseCase.execute(commentId);
      if (_currentComment == null) {
        _setMessage('No se pudo obtener el comentario', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al obtener los detalles del comentario: $e',
          MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createComment(Comment comment) async {
    try {
      _setLoading(true);
      await createCommentUseCase.execute(comment);
      _currentEventId = comment.event;
      await fetchCommentsByEvent(comment.event, 1, 10);
      _setMessage('Comentario creado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al crear el comentario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateComment(String id, Comment comment) async {
    try {
      _setLoading(true);
      await updateCommentUseCase.execute(id, comment);
      await fetchCommentDetails(id);
      _setMessage('Comentario actualizado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al actualizar el comentario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      _setLoading(true);
      await deleteCommentUseCase.execute(id);
      _comments.removeWhere((comment) => comment.id == id);
      if (_currentComment?.id == id) {
        _currentComment = null;
      }
      notifyListeners();
      _setMessage('Comentario eliminado exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al eliminar el comentario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCommentsByEvent(String eventId, int page, int limit) async {
    try {
      _setLoading(true);
      _currentEventId = eventId;
      _comments = await getCommentsByEventUseCase.execute(eventId, page, limit);
      if (_comments.isEmpty && page == 1) {
        _setMessage('No hay comentarios para mostrar', MessageType.success);
      }
      notifyListeners();
    } catch (e) {
      _setMessage(
          'Error al obtener comentarios del evento: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> likeComment(String commentId, String userId) async {
    try {
      await likeCommentUseCase.execute(commentId, userId);

      // Update local state immediately
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index].likeComment();
        notifyListeners();
      }

      if (_currentComment?.id == commentId) {
        _currentComment?.likeComment();
      }

      await fetchCommentLikes(commentId);
      _setMessage('Me gusta agregado', MessageType.success);
    } catch (e) {
      _setMessage('Error al dar me gusta al comentario: $e', MessageType.error);
    }
  }

  Future<void> fetchCommentLikes(String commentId) async {
    try {
      _setLoading(true);
      _commentLikes = await getCommentLikesUseCase.execute(commentId);
      notifyListeners();
    } catch (e) {
      _setMessage('Error al obtener los me gusta del comentario: $e',
          MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reportComment(
      String commentId, Map<String, dynamic> reportData) async {
    try {
      _setLoading(true);
      await reportCommentUseCase.execute(commentId, reportData);
      _setMessage('Comentario reportado exitosamente', MessageType.success);

      // Update the comment state if necessary
      if (_currentComment?.id == commentId) {
        await fetchCommentDetails(commentId);
      } else {
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          await fetchCommentsByEvent(_currentEventId!, 1, 10);
        }
      }
    } catch (e) {
      _setMessage('Error al reportar el comentario: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  // Method to refresh current comments
  Future<void> refreshComments() async {
    if (_currentEventId != null) {
      await fetchCommentsByEvent(_currentEventId!, 1, 10);
    }
  }

  // Method to clear state when changing events
  void clearComments() {
    _comments = [];
    _currentComment = null;
    _commentLikes = [];
    _currentEventId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clear WebSocket listeners
    _socketService.off('new_comment');
    _socketService.off('comment_updated');
    _socketService.off('comment_deleted');
    _socketService.off('comment_liked');
    _socketService.off('comment_reported');

    // Clear state
    clearComments();

    super.dispose();
  }

  // Method to handle pagination
  Future<void> loadMoreComments(String eventId, int page, int limit) async {
    if (!_isLoading) {
      try {
        _setLoading(true);
        final moreComments =
            await getCommentsByEventUseCase.execute(eventId, page, limit);
        _comments.addAll(moreComments);
        notifyListeners();
      } catch (e) {
        _setMessage('Error al cargar más comentarios: $e', MessageType.error);
      } finally {
        _setLoading(false);
      }
    }
  }
}
