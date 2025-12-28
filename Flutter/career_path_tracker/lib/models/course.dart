
enum CourseStatus { notStarted, inProgress, completed }

class Course {
  final int? id;
  final String title;
  final String provider; // e.g., Coursera, Udemy
  final CourseStatus status;
  final double progress; // 0.0 to 1.0

  Course({
    this.id,
    required this.title,
    this.provider = '',
    this.status = CourseStatus.notStarted,
    this.progress = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'status': status.index,
      'progress': progress,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      title: map['title'],
      provider: map['provider'] ?? '',
      status: CourseStatus.values[map['status']],
      progress: map['progress'] ?? 0.0,
    );
  }
}
