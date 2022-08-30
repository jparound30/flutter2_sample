import 'package:flutter/material.dart';
import 'package:flutter2_sample/models/issue.dart';

class PriorityIcon extends StatelessWidget {
  final Priority priority;

  const PriorityIcon({required this.priority});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;

    Icon? icon;
    switch (priority.name) {
      case '高':
        icon = const Icon(
          Icons.arrow_upward,
          color: Colors.red,
        );
        break;
      case '中':
        icon = const Icon(
          Icons.arrow_forward,
        );
        break;
      case '低':
        icon = const Icon(Icons.arrow_downward, color: Colors.grey);
        break;
    }
    return icon ??
        Text(
          priority.name,
          style: textStyle,
        );
  }
}
