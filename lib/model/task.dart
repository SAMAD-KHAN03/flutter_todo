enum Situation { Completed, Incomplete, AllTasks }

class Task {
  Task(
      {required this.id,
      required this.title,
      required this.subject,
      required this.status});
  String id;

  String title;
  String subject;
  Situation status;
}
