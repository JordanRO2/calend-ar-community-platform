// lib/application/use_cases/users/disable_user_use_case.dart

import 'package:frontend/domain/interfaces/user_repository.dart';

class DisableUserUseCase {
  final UserRepository userRepository;

  DisableUserUseCase(this.userRepository);

  Future<void> execute() async {
    try {
      await userRepository.disableUser();
    } catch (e) {
      throw Exception('Error al deshabilitar la cuenta del usuario: $e');
    }
  }
}
