// lib/application/use_cases/users/reset_password_use_case.dart

import 'package:frontend/domain/interfaces/user_repository.dart';

class ResetPasswordUseCase {
  final UserRepository userRepository;

  ResetPasswordUseCase(this.userRepository);

  Future<void> execute(String email) async {
    try {
      await userRepository.resetPassword(email);
    } catch (e) {
      throw Exception(
          'Error al solicitar el restablecimiento de contraseña: $e');
    }
  }
}
