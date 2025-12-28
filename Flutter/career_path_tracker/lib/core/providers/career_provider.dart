import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../../models/interview.dart';
import '../../models/course.dart';
import '../../models/topic.dart';
import '../../models/goal.dart';

class CareerProvider with ChangeNotifier {
  final List<Interview> _interviews = [];
  final List<Course> _courses = [];
  final Map<int, List<Topic>> _topics = {};
  final Map<int, List<SubTopic>> _subTopics = {};
  final List<Goal> _goals = [];

  List<Interview> get interviews => _interviews;
  List<Course> get courses => _courses;
  List<Goal> get goals => _goals;

  // Intervews
  Future<void> fetchInterviews() async {
    final data = await DatabaseHelper.instance.readAllInterviews();
    _interviews.clear();
    _interviews.addAll(data);
    notifyListeners();
  }

  Future<void> addInterview(Interview interview) async {
    await DatabaseHelper.instance.createInterview(interview);
    await fetchInterviews();
  }

  Future<void> updateInterview(Interview interview) async {
    await DatabaseHelper.instance.updateInterview(interview);
    await fetchInterviews();
  }
  
  Future<void> deleteInterview(int id) async {
    await DatabaseHelper.instance.deleteInterview(id);
    await fetchInterviews();
  }

  // Courses
  Future<void> fetchCourses() async {
    final data = await DatabaseHelper.instance.readAllCourses();
    _courses.clear();
    _courses.addAll(data);
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    await DatabaseHelper.instance.createCourse(course);
    await fetchCourses();
  }

  Future<void> updateCourse(Course course) async {
    await DatabaseHelper.instance.updateCourse(course);
    await fetchCourses();
  }

  Future<void> deleteCourse(int id) async {
    await DatabaseHelper.instance.deleteCourse(id);
    await fetchCourses();
  }

  // Topics
  List<Topic> getTopics(int courseId) => _topics[courseId] ?? [];

  Future<void> fetchTopics(int courseId) async {
    final topics = await DatabaseHelper.instance.readTopics(courseId);
    _topics[courseId] = topics;
    notifyListeners();
  }

  Future<void> addTopic(Topic topic) async {
    await DatabaseHelper.instance.createTopic(topic);
    await fetchTopics(topic.courseId);
  }

  Future<void> updateTopic(Topic topic) async {
    await DatabaseHelper.instance.updateTopic(topic);
    await fetchTopics(topic.courseId);
  }

  // SubTopics
  List<SubTopic> getSubTopics(int topicId) => _subTopics[topicId] ?? [];

  Future<void> fetchSubTopics(int topicId) async {
    final subTopics = await DatabaseHelper.instance.readSubTopics(topicId);
    _subTopics[topicId] = subTopics;
    notifyListeners();
  }
  
  Future<void> addSubTopic(SubTopic subTopic) async {
    await DatabaseHelper.instance.createSubTopic(subTopic);
    await fetchSubTopics(subTopic.topicId);
  }

  Future<void> toggleSubTopic(SubTopic subTopic) async {
    final updated = SubTopic(
        id: subTopic.id,
        topicId: subTopic.topicId,
        title: subTopic.title,
        isCompleted: !subTopic.isCompleted);
    await DatabaseHelper.instance.updateSubTopic(updated);
    await fetchSubTopics(subTopic.topicId);
  }

  // Goals
  Future<void> fetchGoals() async {
    final data = await DatabaseHelper.instance.readTodayGoals();
    _goals.clear();
    _goals.addAll(data.map((e) => Goal.fromMap(e)).toList());
    notifyListeners();
  }

  Future<void> addGoal(String title) async {
    await DatabaseHelper.instance.createGoal(title);
    await fetchGoals();
  }

  Future<void> toggleGoal(Goal goal) async {
    await DatabaseHelper.instance.toggleGoal(goal.id!, !goal.isCompleted);
    await fetchGoals();
  }

  Future<void> deleteGoal(int id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    await fetchGoals();
  }
}
