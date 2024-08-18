import 'dart:convert';

class Task {
  String title;
  String time;

  Task(this.title, this.time);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'time': time,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      map['title'],
      map['time'],
    );
  }

  static String encode(List<Task> tasks) => json.encode(
    tasks.map<Map<String, dynamic>>((task) => task.toMap()).toList(),
  );

  static List<Task> decode(String tasks) =>
      (json.decode(tasks) as List<dynamic>)
          .map<Task>((item) => Task.fromMap(item))
          .toList();
}