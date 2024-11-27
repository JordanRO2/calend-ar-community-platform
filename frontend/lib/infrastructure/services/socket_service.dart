import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:frontend/core/config.dart';

class SocketService {
  static SocketService? _instance;
  io.Socket? _socket;
  final Map<String, List<Function(dynamic)>> _eventHandlers = {};

  SocketService._();

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  void initializeSocket() {
    if (_socket?.connected ?? false) return;

    _socket = io.io(
      Config.websocketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      print('Conexión WebSocket establecida');
    });

    _socket?.onDisconnect((_) {
      print('Desconexión WebSocket');
    });

    _socket?.onConnectError((error) {
      print('Error de conexión WebSocket: $error');
    });

    _socket?.onError((error) {
      print('Error WebSocket: $error');
    });
  }

  void on(String event, Function(dynamic) handler) {
    _eventHandlers[event] ??= [];
    _eventHandlers[event]?.add(handler);

    _socket?.on(event, (data) {
      for (var handler in _eventHandlers[event] ?? []) {
        handler(data);
      }
    });
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      _eventHandlers[event]?.remove(handler);
    } else {
      _eventHandlers.remove(event);
    }
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _eventHandlers.clear();
  }

  void reconnect() {
    _socket?.connect();
  }

  bool get isConnected => _socket?.connected ?? false;
}
