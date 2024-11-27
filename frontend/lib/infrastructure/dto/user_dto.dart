// lib/infrastructure/dto/user_dto.dart

class UserDTO {
  final String? id;
  final String name;
  final String email;
  final String? role;
  final bool? isActive;
  final DateTime? createdAt;
  final String? password;
  final String? avatarUrl;

  UserDTO({
    this.id,
    required this.name,
    required this.email,
    this.role,
    this.isActive,
    this.createdAt,
    this.password,
    this.avatarUrl,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      isActive: json['is_active'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}
