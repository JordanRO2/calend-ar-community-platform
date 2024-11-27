// lib/application/use_cases/users/get_user_profile_use_case.dart

import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/interfaces/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository userRepository;

  GetUserProfileUseCase(this.userRepository);

  Future<User?> execute() async {
    try {
      return await userRepository.getUserProfile();
    } catch (e) {
      throw Exception('Error al obtener el perfil del usuario: $e');
    }
  }
}
