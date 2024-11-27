// frontend/lib/domain/entities/event.dart

import 'dart:convert';

class Event {
  final String id;
  final String title;
  final String description;
  final String community;
  final DateTime dateTime;
  final String location;
  final String createdBy;
  final String? imageUrl;
  final List<String> attendees;
  final List<String> comments;
  final int likes;
  final double rating;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime? recurrenceEnd;
  final bool featured;
  final DateTime createdAt;
  final int reportCount;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.community,
    required this.dateTime,
    required this.location,
    required this.createdBy,
    this.imageUrl,
    this.attendees = const [],
    this.comments = const [],
    this.likes = 0,
    this.rating = 0.0,
    this.isRecurring = false,
    this.recurrencePattern,
    this.recurrenceEnd,
    this.featured = false,
    required this.createdAt,
    this.reportCount = 0,
  });

  /// Método fromJson para crear una instancia de Event a partir de un Map<String, dynamic>
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      community: json['community'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      createdBy: json['createdBy'] as String,
      imageUrl: json['imageUrl'] as String?,
      attendees: List<String>.from(json['attendees'] ?? []),
      comments: List<String>.from(json['comments'] ?? []),
      likes: json['likes'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrencePattern: json['recurrencePattern'] as String?,
      recurrenceEnd: json['recurrenceEnd'] != null
          ? DateTime.parse(json['recurrenceEnd'] as String)
          : null,
      featured: json['featured'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      reportCount: json['reportCount'] as int? ?? 0,
    );
  }

  /// Método toJson para serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'community': community,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'createdBy': createdBy,
      'imageUrl': imageUrl,
      'attendees': attendees,
      'comments': comments,
      'likes': likes,
      'rating': rating,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'recurrenceEnd': recurrenceEnd?.toIso8601String(),
      'featured': featured,
      'createdAt': createdAt.toIso8601String(),
      'reportCount': reportCount,
    };
  }

  /// Método fromString para crear una instancia de Event a partir de una cadena
  static Event fromString(String eventString) {
    final json = jsonDecode(eventString) as Map<String, dynamic>;
    return Event.fromJson(json);
  }

  /// Método para verificar si el evento es destacado
  bool get isFeatured => featured;

  /// Método copyWith para crear una nueva instancia con cambios
  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? community,
    DateTime? dateTime,
    String? location,
    String? createdBy,
    String? imageUrl,
    List<String>? attendees,
    List<String>? comments,
    int? likes,
    double? rating,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? recurrenceEnd,
    bool? featured,
    DateTime? createdAt,
    int? reportCount,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      community: community ?? this.community,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
      attendees: attendees ?? List.from(this.attendees),
      comments: comments ?? List.from(this.comments),
      likes: likes ?? this.likes,
      rating: rating ?? this.rating,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      reportCount: reportCount ?? this.reportCount,
    );
  }

  /// Sobrescribir el operador == y hashCode para comparar instancias
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Event &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.community == community &&
        other.dateTime == dateTime &&
        other.location == location &&
        other.createdBy == createdBy &&
        other.imageUrl == imageUrl &&
        other.attendees == attendees &&
        other.comments == comments &&
        other.likes == likes &&
        other.rating == rating &&
        other.isRecurring == isRecurring &&
        other.recurrencePattern == recurrencePattern &&
        other.recurrenceEnd == recurrenceEnd &&
        other.featured == featured &&
        other.createdAt == createdAt &&
        other.reportCount == reportCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        community.hashCode ^
        dateTime.hashCode ^
        location.hashCode ^
        createdBy.hashCode ^
        imageUrl.hashCode ^
        attendees.hashCode ^
        comments.hashCode ^
        likes.hashCode ^
        rating.hashCode ^
        isRecurring.hashCode ^
        recurrencePattern.hashCode ^
        recurrenceEnd.hashCode ^
        featured.hashCode ^
        createdAt.hashCode ^
        reportCount.hashCode;
  }
}
