class User {
  final String id;
  final String name;
  final String email;
  final String role;

  static var currentUser;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? '', // Ensure user_id matches backend
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id, // Ensure correct key
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
