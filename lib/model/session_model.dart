class Session {
  final String id;
  final String appointmentId;
  final String sessionDate;
  final String sessionTime;
  final String coachId;
  final String studentName;
  final String status;
  final String coachName;
  final String serviceType;

  Session({
    required this.id,
    required this.appointmentId,
    required this.sessionDate,
    required this.sessionTime,
    required this.coachId,
    required this.studentName,
    required this.status,
    required this.coachName,
    required this.serviceType,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    print('Session Data: ${json.toString()}');
    
    return Session(
      id: json['session_id']?.toString() ?? '0',
      appointmentId: json['appointment_id']?.toString() ?? '0',
      sessionDate: json['session_date']?.toString() ?? '',
      sessionTime: json['session_time']?.toString() ?? '',
      coachId: json['coach_id']?.toString() ?? '0',
      studentName: json['student_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      coachName: json['coach_name']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? 'Career Coaching',
    );
  }

  Map<String, dynamic> toJson() => {
    'session_id': id,
    'appointment_id': appointmentId,
    'session_date': sessionDate,
    'session_time': sessionTime,
    'coach_id': coachId,
    'student_name': studentName,
    'status': status,
    'coach_name': coachName,
    'service_type': serviceType,
  };

  DateTime get sessionDateTime {
    try {
      return DateTime.parse('$sessionDate $sessionTime');
    } catch (e) {
      return DateTime.now();
    }
  }

bool get isUpcoming {
  if (status == 'RESCHEDULE') return false;
  final now = DateTime.now();
  return sessionDateTime.isAfter(now) && status == 'Accepted';
}

bool get isCancelled => status == 'Cancelled' || status == 'RESCHEDULE';

  bool get isPast {
    final now = DateTime.now();
    return sessionDateTime.isBefore(now) && (status == 'Accepted' || status == 'Completed');
  }

  bool get isPending => status == 'Pending';
  bool get isAccepted => status == 'Accepted';
  bool get isCompleted => status == 'Completed';
  // bool get isCancelled => status == 'Cancelled' || status == 'RESCHEDULE'; // INCLUDES RESCHEDULED
}