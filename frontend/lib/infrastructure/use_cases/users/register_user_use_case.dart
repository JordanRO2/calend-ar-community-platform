// lib/application/use_cases/users/register_user_use_case.dart

import 'package:frontend/domain/interfaces/user_repository.dart';

class RegisterUserUseCase {
  final UserRepository userRepository;

  RegisterUserUseCase(this.userRepository);

  Future<void> execute(String name, String email, String password) async {
    try {
      await userRepository.registerUser(name, email, password);
    } catch (e) {
      throw Exception('Error al registrar el usuario: $e');
    }
  }
}
