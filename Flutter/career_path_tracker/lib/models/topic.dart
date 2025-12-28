
enum StudyStatus { pending, studying, completed }

class Topic {
  final int? id;
  final int courseId;
  final String title;
  final StudyStatus status;

  Topic({
    this.id,
    required this.courseId,
    required this.title,
    this.status = StudyStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'status': status.index,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      courseId: map['courseId'],
      title: map['title'],
      status: StudyStatus.values[map['status']],
    );
  }
}

class SubTopic {
  final int? id;
  final int topicId;
  final String title;
  final bool isCompleted;

  SubTopic({
    this.id,
    required this.topicId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SubTopic.fromMap(Map<String, dynamic> map) {
    return SubTopic(
      id: map['id'],
      topicId: map['topicId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
