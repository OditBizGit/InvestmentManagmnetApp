class AddOrUpdatePhaseResponseModel {
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

  AddOrUpdatePhaseResponseModel({
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

  factory AddOrUpdatePhaseResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AddOrUpdatePhaseResponseModel(
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

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
    }
    return 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static DateTime? _readNullableDate(dynamic value) {
    final date = _readDate(value);
    if (date == null) return null;
    if (date.year <= 1) return null;
    return date;
  }
}
