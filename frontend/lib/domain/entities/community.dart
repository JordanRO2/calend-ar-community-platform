class Community {
  final String id;
  final String name;
  final String description;
  final String admin;
  final List<String> moderators;
  final List<String> members;
  final List<String> events;
  final bool featured;
  final DateTime createdAt;
  final String category;
  final String location;
  final String type;
  final String? imageUrl;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.admin,
    this.moderators = const [],
    this.members = const [],
    this.events = const [],
    this.featured = false,
    DateTime? createdAt,
    required this.category,
    required this.location,
    required this.type,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  bool isFeatured() {
    return featured;
  }

  void addModerator(String userId) {
    if (!moderators.contains(userId)) {
      moderators.add(userId);
    }
  }

  void removeModerator(String userId) {
    moderators.remove(userId);
  }

  void addMember(String userId) {
    if (!members.contains(userId)) {
      members.add(userId);
    }
  }

  void removeMember(String userId) {
    members.remove(userId);
  }
}
