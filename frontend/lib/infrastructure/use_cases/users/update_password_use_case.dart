// lib/application/use_cases/users/update_password_use_case.dart

import 'package:frontend/domain/interfaces/user_repository.dart';

class UpdatePasswordUseCase {
  final UserRepository userRepository;

  UpdatePasswordUseCase(this.userRepository);

  Future<void> execute(String newPassword) async {
    try {
      await userRepository.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Error al actualizar la contraseña: $e');
    }
  }
}
