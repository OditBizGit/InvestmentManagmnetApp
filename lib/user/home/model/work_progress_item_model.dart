class WorkProgressItemModel {
  const WorkProgressItemModel({
    required this.phaseId,
    required this.projectId,
    required this.projectName,
    required this.stageId,
    required this.stageName,
    this.startDate,
    this.dueDate,
    this.constructionTeam,
    this.progress = 0,
    this.status,
    this.description,
    this.progressDate,
  });

  final int phaseId;
  final int projectId;
  final String projectName;
  final int stageId;
  final String stageName;
  final String? startDate;
  final String? dueDate;
  final String? constructionTeam;
  final double progress;
  final String? status;
  final String? description;
  final String? progressDate;

  /// API returns progress as 0–100; LinearProgressIndicator expects 0–1.
  double get progressFraction => (progress / 100).clamp(0.0, 1.0);

  factory WorkProgressItemModel.fromJson(Map<String, dynamic> json) {
    return WorkProgressItemModel(
      phaseId: _readInt(json['phaseId'] ?? json['PhaseId']),
      projectId: _readInt(json['projectId'] ?? json['ProjectId']),
      projectName: (json['projectName'] ?? json['ProjectName'] ?? '').toString(),
      stageId: _readInt(json['stageId'] ?? json['StageId']),
      stageName: (json['stageName'] ?? json['StageName'] ?? '').toString(),
      startDate: _readString(json['startDate'] ?? json['StartDate']),
      dueDate: _readString(json['dueDate'] ?? json['DueDate']),
      constructionTeam:
          _readString(json['constructionTeam'] ?? json['ConstructionTeam']),
      progress: _readDouble(json['progress'] ?? json['Progress']),
      status: _readString(json['status'] ?? json['Status']),
      description: _readString(json['description'] ?? json['Description']),
      progressDate: _readString(json['progressDate'] ?? json['ProgressDate']),
    );
  }

  static String? _readString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
