class ComplaintUiModel {
  const ComplaintUiModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.mobile,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String userId;
  final String username;
  final String email;
  final String mobile;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  ComplaintUiModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? email,
    String? mobile,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ComplaintUiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Temporary sample data for UI preview until API is connected.
List<ComplaintUiModel> sampleComplaints() {
  final now = DateTime.now();
  return [
    ComplaintUiModel(
      id: 'CMP-1001',
      userId: 'USR-204',
      username: 'Anita Sharma',
      email: 'anita.sharma@email.com',
      mobile: '+91 98765 43210',
      message:
          'I paid my installment two days ago but the pending amount still shows as due. Please check and update my payment status.',
      createdAt: now.subtract(const Duration(hours: 5)),
    ),
    ComplaintUiModel(
      id: 'CMP-1002',
      userId: 'USR-318',
      username: 'Rahul Mehta',
      email: 'rahul.mehta@email.com',
      mobile: '+91 91234 56780',
      message:
          'Unable to download the transaction receipt from the investments screen. The download button does nothing after tapping.',
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
    ),
    ComplaintUiModel(
      id: 'CMP-1003',
      userId: 'USR-411',
      username: 'Priya Nair',
      email: 'priya.nair@email.com',
      mobile: '+91 99887 66554',
      message:
          'My profile photo is not updating after upload. I tried both JPEG and PNG formats under 2 MB.',
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    ComplaintUiModel(
      id: 'CMP-1004',
      userId: 'USR-152',
      username: 'Vikram Patel',
      email: 'vikram.patel@email.com',
      mobile: '+91 90123 45678',
      message:
          'Need clarification on the next due date for installment 4. The schedule shows a different date than the email reminder.',
      createdAt: now.subtract(const Duration(days: 6, hours: 8)),
    ),
  ];
}
