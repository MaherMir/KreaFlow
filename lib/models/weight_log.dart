class WeightLog {
  final DateTime date;
  final double weightKg;

  WeightLog({required this.date, required this.weightKg});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
        date: DateTime.parse(json['date']),
        weightKg: (json['weightKg'] as num).toDouble(),
      );
}
