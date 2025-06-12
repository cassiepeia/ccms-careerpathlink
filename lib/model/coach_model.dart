class Coach {
  final int id;
  final String coachName;
  final String coachRole;
  final String displayRole;
  final int userId;
  final int? profileId;

  Coach({
    required this.id,
    required this.coachName,
    required this.coachRole,
    required this.displayRole,
    required this.userId,
    this.profileId,
  });

  factory Coach.fromJson(Map<String, dynamic> json) {
    return Coach(
      id: json['id'],
      coachName: json['coach_name'],
      coachRole: json['coach_role'],
      displayRole: json['display_role'] ?? _mapCoachRole(json['coach_role']),
      userId: json['user_id'],
      profileId: json['profile_id'],
    );
  }

  static String _mapCoachRole(String dbRole) {
    return {
          'Executive Coach': 'Career Coaching',
          'Interview Expert': 'Mock Interview',
          'CV Specialist': 'CV Review',
        }[dbRole] ??
        dbRole;
  }
}
