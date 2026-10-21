class CreateStaffRequestModel {
  final String fullName;
  final String designation;
  final String email;
  final String phoneNumber;
  final String role;

  const CreateStaffRequestModel({
    required this.fullName,
    required this.designation,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'designation': designation,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}