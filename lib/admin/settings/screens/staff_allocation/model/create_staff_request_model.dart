class CreateStaffRequestModel {
  final String fullName;
  final String designation;
  final String email;
  final String phoneNumber;

  const CreateStaffRequestModel({
    required this.fullName,
    required this.designation,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'designation': designation,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}