class CareerCenterProfile {
  final String userId;
  final String name;
  final String contact;
  final String email;
  final String? position;
  final String? address; // Add this line

  CareerCenterProfile({
    required this.userId,
    required this.name,
    required this.contact,
    required this.email,
    this.position,
    this.address, // Add this line
  });

  factory CareerCenterProfile.fromJson(Map<String, dynamic> json) {
    return CareerCenterProfile(
      userId: json['user_id'] ?? 'Not assigned',
      name: json['name'] ?? 'Unknown',
      contact: json['contact'] ?? 'Not provided',
      email: json['email'] ?? 'Not provided',
      position: json['position'],
      address: json['address'], // Add this line
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'contact': contact,
    'email': email,
    'position': position,
    'address': address, // Add this line
  };
}