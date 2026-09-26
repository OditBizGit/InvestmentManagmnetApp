class ProjectStageModel {
  const ProjectStageModel({
    required this.stageId,
    required this.stageName,
  });

  final int stageId;
  final String stageName;

  factory ProjectStageModel.fromJson(Map<String, dynamic> json) {
    return ProjectStageModel(
      stageId: _readInt(json['stageId'] ?? json['StageId']),
      stageName: (json['stageName'] ?? json['StageName'] ?? '').toString().trim(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
