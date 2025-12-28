import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course.dart';
import '../../models/topic.dart';
import '../../core/providers/career_provider.dart';
import '../../core/theme/app_theme.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CareerProvider>(context, listen: false)
            .fetchTopics(widget.course.id!);
      }
    });
  }

  void _addTopic() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Topic'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Topic Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final topic = Topic(
                    courseId: widget.course.id!, title: controller.text);
                await Provider.of<CareerProvider>(context, listen: false)
                    .addTopic(topic);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTopic,
        child: const Icon(Icons.add),
      ),
      body: Consumer<CareerProvider>(
        builder: (context, provider, child) {
          final topics = provider.getTopics(widget.course.id!);
          if (topics.isEmpty) {
            return const Center(child: Text("No topics yet. Add one!"));
          }
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return TopicTile(topic: topics[index]);
            },
          );
        },
      ),
    );
  }
}

class TopicTile extends StatefulWidget {
  final Topic topic;
  const TopicTile({super.key, required this.topic});

  @override
  State<TopicTile> createState() => _TopicTileState();
}

class _TopicTileState extends State<TopicTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CareerProvider>(context, listen: false)
            .fetchSubTopics(widget.topic.id!);
      }
    });
  }

  void _addSubTopic() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add SubTopic'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'SubTopic Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final subTopic = SubTopic(
                    topicId: widget.topic.id!, title: controller.text);
                await Provider.of<CareerProvider>(context, listen: false)
                    .addSubTopic(subTopic);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CareerProvider>(
      builder: (context, provider, child) {
        final subTopics = provider.getSubTopics(widget.topic.id!);
        // We need to fetch the LATEST topic state because widget.topic might be stale 
        // if we rely on the parent list re-rendering only when course changes.
        // Actually, Provider notifyListeners() should rebuild the parent Consumer, 
        // which sends new Topic object to TopicTile.
        // But TopicTile is stateful, so widget.topic updates? Yes.
        
        final isCompleted = widget.topic.status == StudyStatus.completed;
        
        return ExpansionTile(
          shape: const Border.fromBorderSide(BorderSide.none),
          collapsedShape: const Border.fromBorderSide(BorderSide.none),
          leading: IconButton(
            icon: Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? AppTheme.successColor : Colors.white24,
            ),
            onPressed: () {
               final newStatus = isCompleted ? StudyStatus.studying : StudyStatus.completed;
               final updated = Topic(
                 id: widget.topic.id,
                 courseId: widget.topic.courseId,
                 title: widget.topic.title,
                 status: newStatus
               );
               provider.updateTopic(updated);
            },
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(widget.topic.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.white38 : null,
                    )),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Colors.white24),
                onPressed: _addSubTopic,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          children: [
            ...subTopics.map((sub) => CheckboxListTile(
                  value: sub.isCompleted,
                  title: Text(sub.title,
                      style: TextStyle(
                          decoration: sub.isCompleted
                              ? TextDecoration.lineThrough
                              : null)),
                  onChanged: (val) {
                    provider.toggleSubTopic(sub);
                  },
                )),
          ],
        );
      },
    );
  }
}
