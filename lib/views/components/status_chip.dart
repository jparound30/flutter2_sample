import 'package:flutter/material.dart';

import '../../models/issue.dart';
import '../../utils/color_converter.dart';

class StatusChip extends StatelessWidget {
  final Status status;

  const StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        color: ColorConverter.fromString(status.color),
      ),
      child: Text(
        status.name,
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
