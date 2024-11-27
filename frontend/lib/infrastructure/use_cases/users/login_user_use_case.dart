// lib/application/use_cases/users/login_user_use_case.dart

import 'package:frontend/domain/interfaces/user_repository.dart';

class LoginUserUseCase {
  final UserRepository userRepository;

  LoginUserUseCase(this.userRepository);

  Future<void> execute(String email, String password) async {
    try {
      await userRepository.loginUser(email, password);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }
}
