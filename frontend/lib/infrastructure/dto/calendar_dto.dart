// relative path: frontend/lib/infrastructure/dto/calendar_dto.dart

class CalendarDTO {
  final String? id;
  final String name;
  final String owner;
  final List<String> events;
  final bool isPublic;
  final String? sharedUrl;
  final DateTime? createdAt;

  CalendarDTO({
    this.id,
    required this.name,
    required this.owner,
    this.events = const [],
    this.isPublic = true,
    this.sharedUrl,
    this.createdAt,
  });

  /// Crea una instancia de `CalendarDTO` a partir de un JSON.
  factory CalendarDTO.fromJson(Map<String, dynamic> json) {
    return CalendarDTO(
      id: json['id'] as String?,
      name: json['name'] as String,
      owner: json['owner'] as String,
      events: List<String>.from(json['events'] ?? []),
      isPublic: json['is_public'] as bool? ?? true,
      sharedUrl: json['shared_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Convierte la instancia de `CalendarDTO` a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'events': events,
      'is_public': isPublic,
      'shared_url': sharedUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
