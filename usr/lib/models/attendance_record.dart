class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final bool isPresent;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.isPresent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'date': date.toIso8601String(),
      'isPresent': isPresent,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      date: DateTime.parse(json['date']),
      isPresent: json['isPresent'],
    );
  }
}
