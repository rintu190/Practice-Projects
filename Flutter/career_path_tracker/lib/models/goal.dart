
class Goal {
  final int? id;
  final String title;
  final bool isCompleted;
  final String date;

  Goal({this.id, required this.title, this.isCompleted = false, required this.date});

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      date: map['date'],
    );
  }
}
