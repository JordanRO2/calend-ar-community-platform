// lib/domain/interfaces/user_repository.dart

import 'package:frontend/domain/entities/user.dart';
import 'package:image_picker/image_picker.dart';

abstract class UserRepository {
  Future<void> registerUser(String name, String email, String password);
  Future<void> loginUser(String email, String password);
  Future<User?> getUserProfile();
  Future<User> updateUserProfile(User user);
  Future<void> resetPassword(String email);
  Future<void> disableUser();
  Future<bool> validateToken();
  Future<void> updatePassword(String newPassword);
  Future<String> uploadAvatar(XFile avatarFile);
}
