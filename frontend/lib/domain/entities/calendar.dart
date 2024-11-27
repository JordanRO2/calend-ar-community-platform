// frontend/lib/domain/entities/calendar.dart

import 'event.dart';

class Calendar {
  final String id;
  final String name;
  final String owner; // Puede ser el ID de usuario o de una comunidad
  final List<Event> events; // Lista de objetos Event
  final bool isPublic;
  final String sharedUrl;
  final DateTime createdAt;

  const Calendar({
    required this.id,
    required this.name,
    required this.owner,
    this.events = const [], // Lista vacía por defecto
    this.isPublic = true, // Público por defecto
    required this.sharedUrl,
    required this.createdAt,
  });

  /// Método para crear una nueva instancia de Calendar con propiedades actualizadas
  Calendar copyWith({
    String? id,
    String? name,
    String? owner,
    List<Event>? events,
    bool? isPublic,
    String? sharedUrl,
    DateTime? createdAt,
  }) {
    return Calendar(
      id: id ?? this.id,
      name: name ?? this.name,
      owner: owner ?? this.owner,
      events: events ?? List.from(this.events),
      isPublic: isPublic ?? this.isPublic,
      sharedUrl: sharedUrl ?? this.sharedUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Método para verificar si el calendario es público
  bool get isCalendarPublic => isPublic;

  /// Método fromJson para deserializar desde JSON
  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'] as String,
      name: json['name'] as String,
      owner: json['owner'] as String,
      events: (json['events'] as List<dynamic>?)
              ?.map((eventJson) =>
                  Event.fromJson(eventJson as Map<String, dynamic>))
              .toList() ??
          [],
      isPublic: json['isPublic'] as bool? ?? true,
      sharedUrl: json['sharedUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Método toJson para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'events': events.map((event) => event.toJson()).toList(),
      'isPublic': isPublic,
      'sharedUrl': sharedUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Sobrescribir el operador == y hashCode para comparar instancias
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Calendar &&
        other.id == id &&
        other.name == name &&
        other.owner == owner &&
        other.events == events &&
        other.isPublic == isPublic &&
        other.sharedUrl == sharedUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        owner.hashCode ^
        events.hashCode ^
        isPublic.hashCode ^
        sharedUrl.hashCode ^
        createdAt.hashCode;
  }
}
