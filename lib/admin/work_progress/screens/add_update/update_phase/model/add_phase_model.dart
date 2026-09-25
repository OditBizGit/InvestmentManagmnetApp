class AddPhaseRequestModel {
  final String stageName;

  AddPhaseRequestModel({
    required this.stageName,
  });

  Map<String, dynamic> toJson() {
    return {
      'stageName': stageName,
    };
  }
}

class AddPhaseModel {
  final int stageId;
  final String stageName;

  AddPhaseModel({
    required this.stageId,
    required this.stageName,
  });

  factory AddPhaseModel.fromJson(Map<String, dynamic> json) {
    return AddPhaseModel(
      stageId: _readInt(json['stageId'] ?? json['StageId']),
      stageName: (json['stageName'] ?? json['StageName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageId': stageId,
      'stageName': stageName,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
