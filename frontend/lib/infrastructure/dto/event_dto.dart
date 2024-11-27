class EventDTO {
  final String? id;
  final String title;
  final String description;
  final String community;
  final DateTime dateTime;
  final String location;
  final String createdBy;
  final List<String> attendees;
  final List<String> comments;
  final int likes;
  final double rating;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime? recurrenceEnd;
  final bool featured;
  final DateTime? createdAt;
  final int reportCount;
  final String? imageUrl;

  EventDTO({
    this.id,
    required this.title,
    required this.description,
    required this.community,
    required this.dateTime,
    required this.location,
    required this.createdBy,
    this.attendees = const [],
    this.comments = const [],
    this.likes = 0,
    this.rating = 0.0,
    this.isRecurring = false,
    this.recurrencePattern,
    this.recurrenceEnd,
    this.featured = false,
    this.createdAt,
    this.reportCount = 0,
    this.imageUrl,
  });

  factory EventDTO.fromJson(Map<String, dynamic> json) {
    return EventDTO(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      community: json['community'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      location: json['location'] as String,
      createdBy: json['created_by'] as String,
      attendees: List<String>.from(json['attendees'] ?? []),
      comments: List<String>.from(json['comments'] ?? []),
      likes: json['likes'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrencePattern: json['recurrence_pattern'] as String?,
      recurrenceEnd: json['recurrence_end'] != null
          ? DateTime.parse(json['recurrence_end'] as String)
          : null,
      featured: json['featured'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      reportCount: json['report_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'community': community,
      'date_time': dateTime.toIso8601String(),
      'location': location,
      'created_by': createdBy,
      'attendees': attendees,
      'comments': comments,
      'likes': likes,
      'rating': rating,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      'recurrence_end': recurrenceEnd?.toIso8601String(),
      'featured': featured,
      'created_at': createdAt?.toIso8601String(),
      'report_count': reportCount,
      'image_url': imageUrl,
    };
  }
}
