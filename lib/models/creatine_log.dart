class CreatineLog {
  final DateTime date;
  final double amountGrams;

  CreatineLog({required this.date, required this.amountGrams});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amountGrams': amountGrams,
      };

  factory CreatineLog.fromJson(Map<String, dynamic> json) => CreatineLog(
        date: DateTime.parse(json['date']),
        amountGrams: (json['amountGrams'] as num).toDouble(),
      );
}
