class SolveComplaintModel {
  final bool? apiStatus;
  final String? message;
  final String status;

  SolveComplaintModel({
    required this.status,
    this.apiStatus,
    this.message,
  });

  bool get isSolved => status.trim().toLowerCase() == 'solved';

  factory SolveComplaintModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    String solvedStatus = '';

    if (data is String) {
      solvedStatus = data.trim();
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      solvedStatus = (map['status'] ?? map['Status'] ?? '').toString().trim();
    }

    return SolveComplaintModel(
      apiStatus: json['status'] is bool ? json['status'] as bool : null,
      message: json['message']?.toString(),
      status: solvedStatus,
    );
  }
}
