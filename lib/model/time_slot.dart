class TimeSlot {
  final int id;
  final int coachId;
  final String dateSlot;
  final String day;
  final String startTime;
  final String endTime;
  final String status;
  final bool clickable;

  TimeSlot({
    required this.id,
    required this.coachId,
    required this.dateSlot,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.clickable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? 0,
      coachId: json['coach_id'],
      dateSlot: json['date_slot'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'] ?? 'available',
      clickable: json['clickable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coach_id': coachId,
      'date_slot': dateSlot,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'clickable': clickable,
    };
  }
}
