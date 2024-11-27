// lib/presentation/providers/notification_provider.dart

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/notification.dart' as domain;
import 'package:frontend/infrastructure/use_cases/notifications/notifications_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:frontend/presentation/common/message_type.dart';

class NotificationProvider extends ChangeNotifier {
  // Use Cases
  final CreateNotificationUseCase createNotificationUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final GetNotificationByIdUseCase getNotificationByIdUseCase;
  final GetNotificationsByUserUseCase getNotificationsByUserUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  // Inyectado mediante el constructor
  final SocketService _socketService;

  // Variables de estado
  List<domain.Notification> _notifications = [];
  domain.Notification? _selectedNotification;
  String? _message;
  MessageType? _messageType;
  bool _isLoading = false;

  // Getters
  List<domain.Notification> get notifications => _notifications;
  domain.Notification? get selectedNotification => _selectedNotification;
  String? get message => _message;
  MessageType? get messageType => _messageType;
  bool get isLoading => _isLoading;

  /// Constructor que inyecta las dependencias necesarias
  NotificationProvider({
    required this.createNotificationUseCase,
    required this.markNotificationAsReadUseCase,
    required this.getNotificationByIdUseCase,
    required this.getNotificationsByUserUseCase,
    required this.deleteNotificationUseCase,
    required SocketService socketService, // Inyección de SocketService
  }) : _socketService = socketService {
    _initializeWebSocket();
  }

  /// Inicializa los listeners de WebSocket
  void _initializeWebSocket() {
    _socketService.on('notification_created', _handleNotificationCreated);
    _socketService.on('notification_read', _handleNotificationRead);
    _socketService.on('notification_deleted', _handleNotificationDeleted);
  }

  /// Maneja el evento 'notification_created'
  void _handleNotificationCreated(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('user_id') &&
        data.containsKey('notification_id')) {
      final userId = data['user_id'];
      fetchNotificationsByUser(userId);
      _setMessage('Nueva notificación recibida', MessageType.success);
    }
  }

  /// Maneja el evento 'notification_read'
  void _handleNotificationRead(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('notification_id')) {
      final notificationId = data['notification_id'];

      // Actualiza la notificación seleccionada si coincide
      if (_selectedNotification?.id == notificationId) {
        _selectedNotification = _selectedNotification?.markAsRead();
      }

      // Actualiza la lista de notificaciones
      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.markAsRead();
        }
        return notification;
      }).toList();

      notifyListeners();
    }
  }

  /// Maneja el evento 'notification_deleted'
  void _handleNotificationDeleted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('notification_id')) {
      final notificationId = data['notification_id'];

      // Desselecciona la notificación si coincide
      if (_selectedNotification?.id == notificationId) {
        _selectedNotification = null;
      }

      // Elimina la notificación de la lista
      _notifications
          .removeWhere((notification) => notification.id == notificationId);

      notifyListeners();
      _setMessage('Notificación eliminada', MessageType.success);
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

  /// Crea una nueva notificación
  Future<void> createNotification(domain.Notification notification) async {
    try {
      _setLoading(true);
      await createNotificationUseCase.execute(notification);
      await fetchNotificationsByUser(notification.user);
      _setMessage('Notificación creada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al crear la notificación: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Marca una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      _setLoading(true);
      await markNotificationAsReadUseCase.execute(notificationId);

      // Actualiza la notificación seleccionada si coincide
      if (_selectedNotification?.id == notificationId) {
        _selectedNotification = _selectedNotification?.markAsRead();
      }

      // Actualiza la lista de notificaciones
      _notifications = _notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.markAsRead();
        }
        return notification;
      }).toList();

      notifyListeners();
      _setMessage('Notificación marcada como leída', MessageType.success);
    } catch (e) {
      _setMessage(
          'Error al marcar la notificación como leída: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene una notificación por su ID
  Future<void> fetchNotificationById(String notificationId) async {
    try {
      _setLoading(true);
      _selectedNotification =
          await getNotificationByIdUseCase.execute(notificationId);
      if (_selectedNotification == null) {
        _setMessage('Notificación no encontrada', MessageType.error);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al obtener la notificación: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene todas las notificaciones de un usuario
  Future<void> fetchNotificationsByUser(String userId,
      {int page = 1, int limit = 10}) async {
    try {
      _setLoading(true);
      _notifications = await getNotificationsByUserUseCase.execute(
        userId,
        page: page,
        limit: limit,
      );
      if (_notifications.isEmpty && page == 1) {
        _setMessage('No hay notificaciones para mostrar', MessageType.success);
      } else {
        notifyListeners();
      }
    } catch (e) {
      _setMessage('Error al obtener las notificaciones: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina una notificación por su ID
  Future<void> deleteNotification(String notificationId) async {
    try {
      _setLoading(true);
      await deleteNotificationUseCase.execute(notificationId);

      // Desselecciona la notificación si coincide
      if (_selectedNotification?.id == notificationId) {
        _selectedNotification = null;
      }

      // Elimina la notificación de la lista
      _notifications
          .removeWhere((notification) => notification.id == notificationId);

      notifyListeners();
      _setMessage('Notificación eliminada exitosamente', MessageType.success);
    } catch (e) {
      _setMessage('Error al eliminar la notificación: $e', MessageType.error);
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    // Remueve los listeners de WebSocket al destruir el provider
    _socketService.off('notification_created');
    _socketService.off('notification_read');
    _socketService.off('notification_deleted');
    super.dispose();
  }
}
