import 'package:flutter/material.dart';
import 'branch.dart';

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Branch(),
    );
  }
}
