class AddOrUpdatePhaseRequestModel {
  final int stageId;
  final DateTime startDate;
  final DateTime? dueDate;
  final String constructionTeam;
  final int progress;
  final String status;
  final String description;

  AddOrUpdatePhaseRequestModel({
    required this.stageId,
    required this.startDate,
    this.dueDate,
    this.constructionTeam = '',
    required this.progress,
    required this.status,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'stageId': stageId,
      'startDate': startDate.toUtc().toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate!.toUtc().toIso8601String(),
      'constructionTeam': constructionTeam,
      'progress': progress,
      'status': status,
      'description': description,
    };
  }
}
