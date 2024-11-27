// lib/infrastructure/mappers/user_mapper.dart

import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/infrastructure/dto/user_dto.dart';

class UserMapper {
  static UserDTO toDto(User user, {String? password}) {
    return UserDTO(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt,
      password: password,
      avatarUrl: user.avatarUrl,
    );
  }

  static User fromDto(UserDTO dto) {
    return User(
      id: dto.id ?? '',
      name: dto.name,
      email: dto.email,
      role: dto.role ?? 'member',
      isActive: dto.isActive ?? true,
      createdAt: dto.createdAt ?? DateTime.now(),
      avatarUrl: dto.avatarUrl,
    );
  }
}
