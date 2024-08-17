import 'package:flutter/material.dart';
import 'package:to_do_list/myhome.dart';

void main() {
  runApp(MyHome());
}
class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}
