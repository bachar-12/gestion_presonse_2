class AttendanceModel {
  final String id;
  final String sessionId;
  final String studentId;
  final String status; // 'present' | 'absent'
  final DateTime markedAt;

  const AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.markedAt,
  });

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceModel(
      id: id,
      sessionId: (data['sessionId'] ?? '') as String,
      studentId: (data['studentId'] ?? '') as String,
      status: (data['status'] ?? '') as String,
      markedAt: DateTime.tryParse(data['markedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(
              (data['markedAt']?['millisecondsSinceEpoch'] ?? 0) as int,
              isUtc: true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
      'markedAt': markedAt.toIso8601String(),
    };
  }
}

