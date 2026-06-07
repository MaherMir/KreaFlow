class WorkoutLog {
  final String id;
  final DateTime date;
  final String title;
  final String category;
  final int durationMinutes;
  final String notes;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'category': category,
        'durationMinutes': durationMinutes,
        'notes': notes,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] ?? '',
        date: DateTime.parse(json['date']),
        title: json['title'] ?? '',
        category: json['category'] ?? '',
        durationMinutes: json['durationMinutes'] ?? 0,
        notes: json['notes'] ?? '',
      );
}
