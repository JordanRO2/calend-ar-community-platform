// lib/application/use_cases/users/update_user_profile_use_case.dart

import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/interfaces/user_repository.dart';
import 'package:image_picker/image_picker.dart';

class UpdateUserProfileUseCase {
  final UserRepository userRepository;

  UpdateUserProfileUseCase(this.userRepository);

  Future<User> execute({
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    try {
      // Create a User object with the updated information
      final updatedUser = User(
        id: '', // The ID will be managed internally; can be empty here
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );

      // Call the repository to update the user profile
      final user = await userRepository.updateUserProfile(updatedUser);
      return user;
    } catch (e) {
      throw Exception('Error al actualizar el perfil del usuario: $e');
    }
  }

  // Method to upload the avatar image and get the URL
  Future<String> uploadAvatar(XFile avatarFile) async {
    try {
      final avatarUrl = await userRepository.uploadAvatar(avatarFile);
      return avatarUrl;
    } catch (e) {
      throw Exception('Error al subir el avatar: $e');
    }
  }
}
