// lib/infrastructure/repositories/user_repository_impl.dart

import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/domain/interfaces/user_repository.dart';
import 'package:frontend/infrastructure/datasources/user_remote_data_source.dart';
import 'package:frontend/infrastructure/mappers/user_mapper.dart';
import 'package:image_picker/image_picker.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> registerUser(String name, String email, String password) async {
    await remoteDataSource.createUser(name, email, password);
  }

  @override
  Future<void> loginUser(String email, String password) async {
    await remoteDataSource.loginUser(email, password);
  }

  @override
  Future<User> updateUserProfile(User user) async {
    final userDto = UserMapper.toDto(user);
    final updatedUserDto = await remoteDataSource.updateUser(userDto);
    return UserMapper.fromDto(updatedUserDto);
  }

  @override
  Future<void> resetPassword(String email) async {
    await remoteDataSource.resetPassword(email);
  }

  @override
  Future<void> disableUser() async {
    await remoteDataSource.disableUser();
  }

  @override
  Future<User?> getUserProfile() async {
    final userDto = await remoteDataSource.getCurrentUserProfile();
    if (userDto != null) {
      return UserMapper.fromDto(userDto);
    }
    return null;
  }

  @override
  Future<bool> validateToken() async {
    return await remoteDataSource.validateToken();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await remoteDataSource.updatePassword(newPassword);
  }

  @override
  Future<String> uploadAvatar(XFile avatarFile) async {
    return await remoteDataSource.uploadAvatar(avatarFile);
  }
  
}
