class StudentProfilePicture {
  final int id;
  final String userId;
  final String imagePath;
  final String imageUrl; // Added this new field
  final String mimeType;
  final int fileSize;
  final DateTime uploadedAt;

  StudentProfilePicture({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.imageUrl, // Added to constructor
    required this.mimeType,
    required this.fileSize,
    required this.uploadedAt,
  });

  factory StudentProfilePicture.fromJson(Map<String, dynamic> json) {
    return StudentProfilePicture(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      imagePath: json['image_path'] ?? '',
      imageUrl: json['image_url'] ?? '', // Get from JSON
      mimeType: json['mime_type'] ?? 'image/jpeg',
      fileSize: json['file_size'] ?? 0,
      uploadedAt: DateTime.parse(json['uploaded_at'] ?? DateTime.now().toString()),
    );
  }

  // Removed the getter since we're now storing the URL directly
  // from the API response

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'image_url': imageUrl,
      'mime_type': mimeType,
      'file_size': fileSize,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}