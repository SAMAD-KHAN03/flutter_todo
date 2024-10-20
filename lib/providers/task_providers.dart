import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:todo/model/task.dart';

const webaddress =
    'todo-d4568-default-rtdb.asia-southeast1.firebasedatabase.app';
var index = -1;

// StateNotifier for managing tasks
class TaskProviders extends StateNotifier<List<Task>> {
  bool isFetchingData = false;
  bool isUploadingData = false;

  TaskProviders() : super([]) {
    fetchData(); // Fetch tasks on initialization
  }

  // Add a new task
  Future<void> addItem(
      String id, String title, String subject, Situation status) async {
    if (title.isEmpty) return;
    final newItem =
        Task(id: id, title: title, subject: subject, status: status);

    state = [...state, newItem]; // Update the state optimistically
    await _putData(newItem); // Save to Firebase
  }

  // Remove a task
  Future<void> removeItem(Task task) async {
    final Uri taskUrl = Uri.https("$webaddress", '/tasks/${task.id}.json');
    index = state.indexOf(task);

    try {
      final response = await http.delete(taskUrl);

      if (response.statusCode == 200 || response.statusCode == 204) {
        state = state.where((t) => t.id != task.id).toList();
      } else {
        throw Exception('Failed to delete task: ${response.body}');
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Update the status of a task
  Future<void> updateStatus(String id) async {
    final updatedTasks = state.map((task) {
      if (task.id == id) {
        final updatedTask = Task(
          id: task.id,
          title: task.title,
          subject: task.subject,
          status: task.status == Situation.Completed
              ? Situation.Incomplete
              : Situation.Completed,
        );

        _updateTaskInFirebase(updatedTask);
        return updatedTask;
      } else {
        return task;
      }
    }).toList();

    state = updatedTasks;
  }

  // Fetch tasks from Firebase
  Future<void> fetchData() async {
    isFetchingData = true;
    state = [...state];

    final Uri _baseUrl = Uri.https("$webaddress", '/tasks.json');

    try {
      final response = await http.get(_baseUrl);
      if (response.body.isEmpty) {
        isFetchingData = false;
        state = [...state];
        state = [];
        return;
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final loadedTasks = data.entries.map((entry) {
          final taskData = entry.value;
          return Task(
            id: entry.key, // Use entry.key for the ID
            title: taskData['title'],
            subject: taskData['subject'],
            status: Situation.values.firstWhere(
              (s) => s.toString().split('.').last == taskData['status'],
            ),
          );
        }).toList();

        state = loadedTasks;
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    isFetchingData = false;
    state = [...state];
  }

  // Save a task to Firebase
  Future<void> _putData(Task task) async {
    isUploadingData = true;

    final Uri _baseUrl = Uri.https("$webaddress", '/tasks/${task.id}.json');

    try {
      final response = await http.put(
        _baseUrl,
        body: json.encode({
          'title': task.title,
          'subject': task.subject,
          'status': task.status.toString().split('.').last,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save task');
      }
    } catch (e) {
      print('Error saving task: $e');
    }

    isUploadingData = false;
    state = [...state];
  }

  // Update a task in Firebase
  Future<void> _updateTaskInFirebase(Task task) async {
    final Uri taskUrl = Uri.https("$webaddress", '/tasks/${task.id}.json');

    try {
      final response = await http.put(
        taskUrl,
        body: json.encode({
          'title': task.title,
          'subject': task.subject,
          'status': task.status.toString().split('.').last,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }
}

// StateNotifier for filtering tasks
class FilterProviders extends StateNotifier<List<Task>> {
  List<Task> alltask;
  FilterProviders(this.alltask) : super(alltask);

  // void updateTasks(List<Task> allTasks) {
  //   state = allTasks;
  // }

  void completedFilter() {
    state =
        alltask.where((task) => task.status == Situation.Completed).toList();
  }

  void incompleteFilter() {
    state =
        alltask.where((task) => task.status == Situation.Incomplete).toList();
  }

  void resetFilter() {
    state = alltask;
  }
}

// Provider for task management
final taskprovider = StateNotifierProvider<TaskProviders, List<Task>>((ref) {
  final taskNotifier = TaskProviders();
  return taskNotifier;
});

// Provider for task filtering
final filterprovider =
    StateNotifierProvider<FilterProviders, List<Task>>((ref) {
  final allTask = ref.watch(taskprovider);
  return FilterProviders(allTask);
});
