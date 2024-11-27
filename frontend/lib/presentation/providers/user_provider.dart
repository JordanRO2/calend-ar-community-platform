// frontend/lib/presentation/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/infrastructure/use_cases/users/users_use_cases.dart';
import 'package:frontend/infrastructure/services/socket_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/common/message_type.dart';

class UserProvider extends ChangeNotifier {
  // Use Cases
  final RegisterUserUseCase registerUserUseCase;
  final LoginUserUseCase loginUserUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final ValidateTokenUseCase validateTokenUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final DisableUserUseCase disableUserUseCase;

  // Inyectado mediante el constructor
  final FlutterSecureStorage _secureStorage;
  final SocketService _socketService;

  // Estado
  User? _currentUser;
  bool _isLoading = false;
  String? _message;
  MessageType? _messageType;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get message => _message;
  MessageType? get messageType => _messageType;

  /// Constructor que inyecta las dependencias necesarias
  UserProvider({
    required this.registerUserUseCase,
    required this.loginUserUseCase,
    required this.getUserProfileUseCase,
    required this.validateTokenUseCase,
    required this.updateUserProfileUseCase,
    required this.updatePasswordUseCase,
    required this.resetPasswordUseCase,
    required this.disableUserUseCase,
    required FlutterSecureStorage
        secureStorage, // Inyección de FlutterSecureStorage
    required SocketService socketService, // Inyección de SocketService
  })  : _secureStorage = secureStorage,
        _socketService = socketService {
    _initializeWebSocket();
    _validateTokenSilently(); // Validación inicial del token
  }

  /// Inicializa los listeners de WebSocket
  void _initializeWebSocket() {
    _socketService.on('profile_updated', _handleProfileUpdated);
    _socketService.on('password_updated', _handlePasswordUpdated);
    _socketService.on('account_disabled', _handleAccountDisabled);
  }

  /// Maneja el evento 'profile_updated'
  void _handleProfileUpdated(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('user_id') &&
        _currentUser?.id == data['user_id']) {
      _loadUserProfile();
      _setMessage(AppTexts.profileUpdatedSuccess, MessageType.success);
    }
  }

  /// Maneja el evento 'password_updated'
  void _handlePasswordUpdated(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('user_id') &&
        _currentUser?.id == data['user_id']) {
      _setMessage(AppTexts.passwordUpdatedSuccess, MessageType.success);
    }
  }

  /// Maneja el evento 'account_disabled'
  void _handleAccountDisabled(dynamic data) {
    if (data is Map<String, dynamic> &&
        data.containsKey('user_id') &&
        _currentUser?.id == data['user_id']) {
      logout();
      _setMessage(AppTexts.accountDisabled, MessageType.error);
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

  /// Verifica la autenticación del usuario
  Future<bool> checkAuthentication() async {
    if (isAuthenticated) return true;
    return await _validateTokenSilently();
  }

  /// Valida el token de manera silenciosa
  Future<bool> _validateTokenSilently() async {
    try {
      final isValid = await validateTokenUseCase.execute();
      if (isValid) {
        await _loadUserProfile();
      }
      return isValid;
    } catch (e) {
      debugPrint('Error en la validación del token: $e');
      return false;
    }
  }

  /// Carga el perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      final user = await getUserProfileUseCase.execute();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      _currentUser = null;
      notifyListeners();
      debugPrint('Error al cargar el perfil del usuario: $e');
    }
  }

  /// Registra un nuevo usuario
  Future<void> registerUser(String name, String email, String password) async {
    try {
      _setLoading(true);
      await registerUserUseCase.execute(name, email, password);
      await loginUser(email, password);
      _setMessage(AppTexts.registerSuccess, MessageType.success);
    } catch (e) {
      _setMessage(AppTexts.registrationError, MessageType.error);
      debugPrint('Error en el registro del usuario: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia sesión de un usuario
  Future<void> loginUser(String email, String password) async {
    try {
      _setLoading(true);
      await loginUserUseCase.execute(email, password);
      await _loadUserProfile();
      _setMessage(AppTexts.loginSuccess, MessageType.success);
    } catch (e) {
      _setMessage(AppTexts.loginError, MessageType.error);
      debugPrint('Error en el inicio de sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza el perfil del usuario
  Future<void> updateProfile({
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);
      final updatedUser = await updateUserProfileUseCase.execute(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );
      _currentUser = updatedUser;
      notifyListeners();
      _setMessage(AppTexts.profileUpdatedSuccess, MessageType.success);
    } catch (e) {
      _setMessage(AppTexts.profileUpdateError, MessageType.error);
      debugPrint('Error al actualizar el perfil: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sube una imagen de avatar y obtiene la URL
  Future<String?> uploadAvatar(XFile avatarFile) async {
    try {
      _setLoading(true);
      final avatarUrl = await updateUserProfileUseCase.uploadAvatar(avatarFile);
      return avatarUrl;
    } catch (e) {
      _setMessage(AppTexts.avatarUploadError, MessageType.error);
      debugPrint('Error al subir el avatar: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza la contraseña del usuario
  Future<void> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      await updatePasswordUseCase.execute(newPassword);
      _setMessage(AppTexts.passwordUpdatedSuccess, MessageType.success);
    } catch (e) {
      _setMessage(AppTexts.passwordUpdateError, MessageType.error);
      debugPrint('Error al actualizar la contraseña: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Resetea la contraseña del usuario
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await resetPasswordUseCase.execute(email);
      _setMessage(AppTexts.resetPasswordEmailSent, MessageType.success);
    } catch (e) {
      _setMessage(AppTexts.resetPasswordError, MessageType.error);
      debugPrint('Error al resetear la contraseña: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Deshabilita la cuenta del usuario
  Future<void> disableUser() async {
    try {
      _setLoading(true);
      await disableUserUseCase.execute();
      await logout();
      _setMessage(AppTexts.accountDisabled, MessageType.error);
    } catch (e) {
      _setMessage(AppTexts.disableAccountError, MessageType.error);
      debugPrint('Error al deshabilitar la cuenta: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    try {
      _setLoading(true);
      _currentUser = null;
      await _secureStorage.deleteAll();
      notifyListeners();
      _setMessage(AppTexts.logoutSuccess, MessageType.success);
    } catch (e) {
      _setMessage(AppTexts.logoutError, MessageType.error);
      debugPrint('Error al cerrar la sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    // Remueve los listeners de WebSocket al destruir el provider
    _socketService.off('profile_updated');
    _socketService.off('password_updated');
    _socketService.off('account_disabled');
    super.dispose();
  }
}
