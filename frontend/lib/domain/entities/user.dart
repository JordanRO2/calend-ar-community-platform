// lib/domain/entities/user.dart

class User {
  final String id;
  final String name;
  final String email;
  final String role; // "admin", "moderator", "member"
  final bool isActive;
  final DateTime createdAt;
  final String? avatarUrl; // Optional attribute for user avatar

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'member',
    this.isActive = true,
    DateTime? createdAt,
    this.avatarUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  // Method to check if the user is an admin
  bool isAdmin() {
    return role == 'admin';
  }

  // Method to check if the user is a moderator
  bool isModerator() {
    return role == 'moderator';
  }

  // Method copyWith for partial copies
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }
}
