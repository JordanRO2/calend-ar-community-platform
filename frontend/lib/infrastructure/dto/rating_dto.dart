// relative path: frontend/lib/infrastructure/dto/rating_dto.dart

class RatingDTO {
  final String? id;
  final String event;
  final String user;
  final int score;
  final DateTime? createdAt;

  RatingDTO({
    this.id,
    required this.event,
    required this.user,
    required this.score,
    this.createdAt,
  });

  /// Crea una instancia de RatingDTO a partir de un JSON.
  factory RatingDTO.fromJson(Map<String, dynamic> json) {
    return RatingDTO(
      id: json['id'],
      event: json['event'],
      user: json['user'],
      score: json['score'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Serializa la instancia de RatingDTO a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'user': user,
      'score': score,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
