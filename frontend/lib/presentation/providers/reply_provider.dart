// lib/presentation/providers/reply_provider.dart

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/reply.dart';
import 'package:frontend/infrastructure/use_cases/replies/replies_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:collection/collection.dart'; // Asegúrate de mantener esta importación
import 'package:frontend/presentation/common/message_type.dart';

class ReplyProvider extends ChangeNotifier {
  // Use Cases
  final CreateReplyUseCase createReplyUseCase;
  final GetReplyByIdUseCase getReplyByIdUseCase;
  final UpdateReplyUseCase updateReplyUseCase;
  final DeleteReplyUseCase deleteReplyUseCase;
  final GetRepliesByCommentUseCase getRepliesByCommentUseCase;
  final LikeReplyUseCase likeReplyUseCase;
  final GetReplyLikesUseCase getReplyLikesUseCase;

  // Inyectado mediante el constructor
  final SocketService _socketService;

  // Estado
  List<Reply> _replies = [];
  Reply? _currentReply;
  String? _message;
  MessageType? _messageType;
  bool _isLoading = false;
  String? _currentCommentId;
  Reply? _selectedReply;
  Map<String, List<String>> _replyLikes = {};

  // Getters
  List<Reply> get replies => _replies;
  Reply? get currentReply => _currentReply;
  String? get message => _message;
  MessageType? get messageType => _messageType;
  bool get isLoading => _isLoading;
  Map<String, List<String>> get replyLikes => _replyLikes;

  /// Constructor que inyecta las dependencias necesarias
  ReplyProvider({
    required this.createReplyUseCase,
    required this.getReplyByIdUseCase,
    required this.updateReplyUseCase,
    required this.deleteReplyUseCase,
    required this.getRepliesByCommentUseCase,
    required this.likeReplyUseCase,
    required this.getReplyLikesUseCase,
    required SocketService socketService, // Inyección de SocketService
  }) : _socketService = socketService {
    _initializeWebSocket();
  }

  /// Inicializa los listeners de WebSocket
  void _initializeWebSocket() {
    _socketService.on('new_reply', _handleNewReply);
    _socketService.on('reply_deleted', _handleReplyDeleted);
  }

  /// Maneja el evento 'new_reply'
  void _handleNewReply(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('comment_id') &&
        data.containsKey('reply_id')) {
      final commentId = data['comment_id'];
      if (_currentCommentId == commentId) {
        fetchReplies(commentId, 1, 10);
      }
      _setMessage('Nueva respuesta agregada', MessageType.success);
    }
  }

  /// Maneja el evento 'reply_deleted'
  void _handleReplyDeleted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('reply_id')) {
      final replyId = data['reply_id'];
      if (_currentReply?.id == replyId) {
        _currentReply = null;
      }
      _replies.removeWhere((reply) => reply.id == replyId);
      _replyLikes.remove(replyId);
      notifyListeners();
      _setMessage('Respuesta eliminada', MessageType.success);
    }
  }

  /// Métodos utilitarios para gestionar el estado
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage(String message, MessageType type) {
    _message = message;
    _messageType = type;
    notifyListeners();
  }

  /// Limpia los mensajes de estado
  void clearMessage() {
    _message = null;
    _messageType = null;
    notifyListeners();
  }

  /// CRUD Operations

  /// Crea una nueva respuesta
  Future<void> createReply(Reply reply) async {
    try {
      _setLoading(true);
      final replyId = await createReplyUseCase.execute(reply);
      if (replyId != null) {
        _currentCommentId = reply.parentComment;
        await fetchReplies(reply.parentComment, 1, 10);
        _setMessage('Respuesta creada exitosamente', MessageType.success);
      } else {
        _setMessage('Error al crear la respuesta', MessageType.error);
      }
    } catch (e) {
      _setMessage('Error al crear la respuesta: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza una respuesta existente
  Future<void> updateReply(String replyId, Reply updatedReply) async {
    try {
      _setLoading(true);
      await updateReplyUseCase.execute(replyId, updatedReply);
      final index = _replies.indexWhere((r) => r.id == replyId);
      if (index != -1) {
        _replies[index] = updatedReply;
        notifyListeners();
        _setMessage('Respuesta actualizada exitosamente', MessageType.success);
      }
    } catch (e) {
      _setMessage('Error al actualizar la respuesta: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina una respuesta
  Future<void> deleteReply(String replyId) async {
    try {
      _setLoading(true);
      await deleteReplyUseCase.execute(replyId);
      if (_currentReply?.id == replyId) {
        _currentReply = null;
      }
      _replies.removeWhere((reply) => reply.id == replyId);
      _replyLikes.remove(replyId);
      notifyListeners();
      _setMessage('Respuesta eliminada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al eliminar la respuesta: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene una respuesta por su ID
  Future<void> fetchReplyById(String replyId) async {
    try {
      _setLoading(true);
      _selectedReply = await getReplyByIdUseCase.execute(replyId);
      if (_selectedReply == null) {
        _setMessage('Respuesta no encontrada', MessageType.error);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al obtener la respuesta: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene todas las respuestas de un comentario
  Future<void> fetchReplies(String commentId, int page, int limit) async {
    try {
      _setLoading(true);
      _currentCommentId = commentId;
      _replies =
          await getRepliesByCommentUseCase.execute(commentId, page, limit);
      if (_replies.isEmpty && page == 1) {
        _setMessage('No hay respuestas para mostrar', MessageType.success);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al obtener las respuestas: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Da me gusta a una respuesta
  Future<void> likeReply(String replyId, String userId) async {
    try {
      await likeReplyUseCase.execute(replyId, userId);

      // Actualiza el estado local inmediatamente
      final reply = _replies.firstWhereOrNull((r) => r.id == replyId);
      if (reply != null) {
        reply.addLike();
        notifyListeners();
      }

      // Actualiza los me gusta
      await fetchReplyLikes(replyId);

      _setMessage('Me gusta agregado', MessageType.success);
    } catch (e) {
      _setMessage('Error al dar me gusta: $e', MessageType.error);
    }
  }

  /// Obtiene los me gusta de una respuesta
  Future<void> fetchReplyLikes(String replyId) async {
    try {
      _setLoading(true);
      final likes = await getReplyLikesUseCase.execute(replyId);
      _replyLikes[replyId] = likes;
      notifyListeners();
    } catch (e) {
      _setMessage('Error al obtener los me gusta: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Limpia los me gusta de una respuesta
  void clearReplyLikes(String replyId) {
    _replyLikes.remove(replyId);
    notifyListeners();
  }

  /// Selecciona una respuesta específica
  void selectReply(Reply? reply) {
    _currentReply = reply;
    notifyListeners();
  }

  /// Limpia todas las respuestas y estados relacionados
  void clearReplies() {
    _replies = [];
    _currentReply = null;
    _currentCommentId = null;
    _replyLikes = {};
    notifyListeners();
  }

  /// Limpia todos los estados de mensaje
  void clearAllMessages() {
    _message = null;
    _messageType = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Remueve los listeners de WebSocket al destruir el provider
    _socketService.off('new_reply');
    _socketService.off('reply_deleted');
    super.dispose();
  }
}
