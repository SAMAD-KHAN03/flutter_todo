// Import statements
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/providers/task_providers.dart';
import 'package:todo/model/task.dart';

class TaskCards extends ConsumerStatefulWidget {
  final List<Task> task;
  const TaskCards({super.key, required this.task});
  @override
  ConsumerState<TaskCards> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCards> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.task.length,
      itemBuilder: (ctx, index) {
        final taskItem = widget.task[index];
        return Dismissible(
          key: ValueKey(taskItem.id),
          background: Container(
            color: generateColor(index),
            padding: EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            // Call to remove the item
            ref.read(taskprovider.notifier).removeItem(taskItem);
          },
          child: Card(
            color: Colors.white,
            elevation: 6,
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  taskItem.status == Situation.Completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: taskItem.status == Situation.Completed
                      ? Colors.green
                      : Colors.grey,
                ),
                onPressed: () {
                  ref.read(taskprovider.notifier).updateStatus(taskItem.id);
                },
              ),
              title: Text(
                taskItem.title,
                style: TextStyle(
                  decoration: taskItem.status == Situation.Completed
                      ? TextDecoration.lineThrough
                      : null,
                  color: taskItem.status == Situation.Completed
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
              subtitle: Text(
                taskItem.subject,
                style: TextStyle(
                  decoration: taskItem.status == Situation.Completed
                      ? TextDecoration.lineThrough
                      : null,
                  color: taskItem.status == Situation.Completed
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
              trailing: IconButton(
                color: Colors.grey,
                icon: const Icon(Icons.delete),
                onPressed: () {
                  ref.read(taskprovider.notifier).removeItem(taskItem);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to generate a random color
  Color generateColor(int index) {
    int r = Random().nextInt(256);
    int g = Random().nextInt(156) + 100; // Adjusting to prevent too dark colors
    int b = Random().nextInt(200) + 56; // Adjusting to prevent too dark colors
    return Color.fromARGB(255, r, g, b);
  }
}

// Update your TaskProviders or taskprovider notifiers accordingly
// Particularly, make sure your removeItem method in your StateNotifier is well implemented.
