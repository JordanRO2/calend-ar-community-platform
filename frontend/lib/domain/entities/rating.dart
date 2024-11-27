class Rating {
  final String id;
  final String event;
  final String user;
  final int score;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.event,
    required this.user,
    required this.score,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Método para validar que el puntaje esté entre 1 y 5
  bool isValidScore() {
    return score >= 1 && score <= 5;
  }
}
