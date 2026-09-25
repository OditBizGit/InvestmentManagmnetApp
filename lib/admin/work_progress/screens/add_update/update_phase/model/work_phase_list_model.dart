class WorkPhaseListModel {
  final int phaseId;
  final int projectId;
  final String projectName;
  final int stageId;
  final String stageName;
  final DateTime startDate;
  final DateTime? dueDate;
  final String constructionTeam;
  final int progress;
  final String status;
  final String description;
  final DateTime progressDate;

  WorkPhaseListModel({
    required this.phaseId,
    required this.projectId,
    required this.projectName,
    required this.stageId,
    required this.stageName,
    required this.startDate,
    this.dueDate,
    required this.constructionTeam,
    required this.progress,
    required this.status,
    required this.description,
    required this.progressDate,
  });

  factory WorkPhaseListModel.fromJson(Map<String, dynamic> json) {
    return WorkPhaseListModel(
      phaseId: _readInt(json['phaseId'] ?? json['PhaseId']),
      projectId: _readInt(json['projectId'] ?? json['ProjectId']),
      projectName:
          (json['projectName'] ?? json['ProjectName'] ?? '').toString(),
      stageId: _readInt(json['stageId'] ?? json['StageId']),
      stageName: (json['stageName'] ?? json['StageName'] ?? '').toString(),
      startDate: _readDate(json['startDate'] ?? json['StartDate']) ??
          DateTime.now(),
      dueDate: _readNullableDate(json['dueDate'] ?? json['DueDate']),
      constructionTeam: (json['constructionTeam'] ??
              json['ConstructionTeam'] ??
              '')
          .toString(),
      progress: _readInt(json['progress'] ?? json['Progress']),
      status: (json['status'] ?? json['Status'] ?? '').toString(),
      description:
          (json['description'] ?? json['Description'] ?? '').toString(),
      progressDate: _readDate(json['progressDate'] ?? json['ProgressDate']) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phaseId': phaseId,
      'projectId': projectId,
      'projectName': projectName,
      'stageId': stageId,
      'stageName': stageName,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'constructionTeam': constructionTeam,
      'progress': progress,
      'status': status,
      'description': description,
      'progressDate': progressDate.toIso8601String(),
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  /// Treats missing / default server dates as no due date.
  static DateTime? _readNullableDate(dynamic value) {
    final date = _readDate(value);
    if (date == null) return null;
    // API sometimes returns DateTime.MinValue when due date is unset.
    if (date.year <= 1) return null;
    return date;
  }
}
