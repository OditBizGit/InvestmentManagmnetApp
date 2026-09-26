class WorkProgressGraphPointModel {
  const WorkProgressGraphPointModel({
    required this.date,
    required this.progress,
  });

  final DateTime? date;
  final double progress;

  /// API returns progress as 0–100; chart expects 0–1.
  double get progressFraction => (progress / 100).clamp(0.0, 1.0);

  factory WorkProgressGraphPointModel.fromJson(Map<String, dynamic> json) {
    return WorkProgressGraphPointModel(
      date: _readDate(json['date'] ?? json['Date']),
      progress: _readDouble(json['progress'] ?? json['Progress']),
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
