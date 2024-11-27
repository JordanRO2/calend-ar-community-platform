// lib/application/use_cases/users/validate_token_use_case.dart

import 'package:frontend/domain/interfaces/user_repository.dart';

class ValidateTokenUseCase {
  final UserRepository userRepository;

  ValidateTokenUseCase(this.userRepository);

  Future<bool> execute() async {
    try {
      return await userRepository.validateToken();
    } catch (e) {
      throw Exception('Error al validar el token: $e');
    }
  }
}
