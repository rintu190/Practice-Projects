
enum InterviewStatus { scheduled, attended, selected, rejected }
enum CompanyType { product, service }

class Interview {
  final int? id;
  final String companyName;
  final String jobRole;
  final DateTime date;
  final String location;
  final InterviewStatus status;
  final String notes;
  final CompanyType companyType;

  Interview({
    this.id,
    required this.companyName,
    required this.jobRole,
    required this.date,
    required this.location,
    required this.status,
    this.notes = '',
    this.companyType = CompanyType.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'jobRole': jobRole,
      'date': date.toIso8601String(),
      'location': location,
      'status': status.index,
      'notes': notes,
      'companyType': companyType.index,
    };
  }

  factory Interview.fromMap(Map<String, dynamic> map) {
    return Interview(
      id: map['id'] as int?,
      companyName: (map['companyName'] ?? 'Unknown Company').toString(),
      jobRole: (map['jobRole'] ?? 'Unknown Role').toString(),
      date: map['date'] != null ? DateTime.parse(map['date'].toString()) : DateTime.now(),
      location: (map['location'] ?? '').toString(),
      status: map['status'] != null ? InterviewStatus.values[map['status'] as int] : InterviewStatus.scheduled,
      notes: (map['notes'] ?? '').toString(),
      companyType: map['companyType'] != null 
        ? CompanyType.values[map['companyType'] as int] 
        : CompanyType.product,
    );
  }

  Interview copyWith({
    int? id,
    String? companyName,
    String? jobRole,
    DateTime? date,
    String? location,
    InterviewStatus? status,
    String? notes,
    CompanyType? companyType,
  }) {
    return Interview(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      jobRole: jobRole ?? this.jobRole,
      date: date ?? this.date,
      location: location ?? this.location,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      companyType: companyType ?? this.companyType,
    );
  }
}
