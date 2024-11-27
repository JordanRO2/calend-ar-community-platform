// lib/infrastructure/datasources/user_remote_data_source.dart

import 'dart:async';
import 'package:frontend/infrastructure/dto/user_dto.dart';
import 'package:frontend/infrastructure/network/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart'; // Only for FormData and MultipartFile types

class UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSource(this.apiClient);

  // Obtener el perfil del usuario autenticado
  Future<UserDTO?> getCurrentUserProfile() async {
    try {
      final response = await apiClient.get('/api/users/profile');
      if (response.statusCode == 200 && response.data != null) {
        return UserDTO.fromJson(response.data);
      } else {
        print('Error al obtener el perfil de usuario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener el perfil de usuario: $e');
      return null;
    }
  }

  // Registrar un nuevo usuario
  Future<void> createUser(String name, String email, String password) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
      };
      final response = await apiClient.post('/api/users/register', data: data);
      if (response.statusCode == 201) {
        final tokens = response.data;
        await apiClient.storeTokens(tokens);
      } else {
        throw Exception(
            'Fallo al registrar usuario: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción al registrar usuario: $e');
      rethrow;
    }
  }

  // Autenticar un usuario e iniciar sesión
  Future<void> loginUser(String email, String password) async {
    try {
      final response = await apiClient.post('/api/users/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        final tokens = response.data;
        await apiClient.storeTokens(tokens);
      } else {
        throw Exception('Inicio de sesión fallido: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción durante el inicio de sesión: $e');
      rethrow;
    }
  }

  // Actualizar el perfil del usuario
  Future<UserDTO> updateUser(UserDTO user) async {
    try {
      final response =
          await apiClient.put('/api/users/update', data: user.toJson());
      if (response.statusCode == 200 && response.data != null) {
        return UserDTO.fromJson(response.data);
      } else {
        throw Exception(
            'Fallo al actualizar el perfil: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción al actualizar el perfil: $e');
      rethrow;
    }
  }

  // Subir la imagen del avatar y obtener la URL
  Future<String> uploadAvatar(XFile avatarFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.name,
        ),
      });

      final response =
          await apiClient.post('/api/users/upload-avatar', data: formData);

      if (response.statusCode == 200 && response.data != null) {
        return response.data['avatar_url'];
      } else {
        throw Exception('Fallo al subir el avatar: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción al subir el avatar: $e');
      rethrow;
    }
  }

  // Solicitar un restablecimiento de contraseña
  Future<void> resetPassword(String email) async {
    try {
      final response = await apiClient.post('/api/users/reset-password', data: {
        'email': email,
      });
      if (response.statusCode != 200) {
        throw Exception(
            'Fallo al restablecer la contraseña: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción al restablecer la contraseña: $e');
      rethrow;
    }
  }

  // Deshabilitar la cuenta del usuario autenticado
  Future<void> disableUser() async {
    try {
      final response = await apiClient.post('/api/users/disable');
      if (response.statusCode != 200) {
        throw Exception(
            'Fallo al deshabilitar la cuenta: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción al deshabilitar la cuenta: $e');
      rethrow;
    }
  }

  // Validar el token de acceso actual
  Future<bool> validateToken() async {
    try {
      final response = await apiClient.get('/api/users/profile');
      if (response.statusCode == 200 && response.data != null) {
        print('Token válido.');
        return true; // Token válido
      } else if (response.statusCode == 401) {
        print('Token inválido o expirado.');
        return false;
      } else {
        print(
            'Error desconocido al validar el token: ${response.statusCode}, ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error de red al validar el token: $e');
      return false;
    }
  }

  // Actualizar la contraseña del usuario
  Future<void> updatePassword(String newPassword) async {
    try {
      final response =
          await apiClient.post('/api/users/update-password', data: {
        'new_password': newPassword,
      });
      if (response.statusCode != 200) {
        throw Exception(
            'Fallo al actualizar la contraseña: ${response.data['error']}');
      }
    } catch (e) {
      print('Excepción al actualizar la contraseña: $e');
      rethrow;
    }
  }
}
