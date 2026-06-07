class HydrationLog {
  final DateTime date;
  final double amountMl;

  HydrationLog({required this.date, required this.amountMl});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amountMl': amountMl,
      };

  factory HydrationLog.fromJson(Map<String, dynamic> json) => HydrationLog(
        date: DateTime.parse(json['date']),
        amountMl: (json['amountMl'] as num).toDouble(),
      );
}
