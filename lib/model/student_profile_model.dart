class StudentProfile {
  String studentNo;
  String studentName;
  String department;
  String course;
  String level;
  String address;
  String contact;
  String email;
  String? profileImage; // Add this as nullable

  StudentProfile({
    required this.studentNo,
    required this.studentName,
    required this.department,
    required this.course,
    required this.level,
    required this.address,
    required this.contact,
    required this.email,
    this.profileImage, // Add this
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentNo: json['user_id'] ?? '',
      studentName: json['student_name'] ?? '',
      department: json['department'] ?? '',
      course: json['course'] ?? '',
      level: json['level'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      profileImage:
          json['profile_image'] ?? json['avatar_url'], // Add this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_no': studentNo,
      'student_name': studentName,
      'department': department,
      'course': course,
      'level': level,
      'address': address,
      'contact': contact,
      'email': email,
      'profile_image': profileImage, // Add this
    };
  }
}
