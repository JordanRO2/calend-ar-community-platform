class CommunityDTO {
  final String? id;
  final String name;
  final String description;
  final String admin;
  final List<String> moderators;
  final List<String> members;
  final List<String> events;
  final bool featured;
  final DateTime? createdAt;
  final String category;
  final String location;
  final String type;
  final String? imageUrl;

  CommunityDTO({
    this.id,
    required this.name,
    required this.description,
    required this.admin,
    this.moderators = const [],
    this.members = const [],
    this.events = const [],
    this.featured = false,
    this.createdAt,
    required this.category,
    required this.location,
    required this.type,
    this.imageUrl,
  });

  factory CommunityDTO.fromJson(Map<String, dynamic> json) {
    return CommunityDTO(
      id: json['id'] ?? json['_id'], // Manejar ambos casos
      name: json['name'],
      description: json['description'],
      admin: json['admin'],
      moderators: List<String>.from(json['moderators'] ?? []),
      members: List<String>.from(json['members'] ?? []),
      events: List<String>.from(json['events'] ?? []),
      featured: json['featured'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null, // Cambio de createdAt a created_at
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'], // Manejar ambos casos
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'admin': admin,
      'moderators': moderators,
      'members': members,
      'events': events,
      'featured': featured,
      'createdAt': createdAt?.toIso8601String(),
      'category': category,
      'location': location,
      'type': type,
      'imageUrl': imageUrl,
    };
  }
}
