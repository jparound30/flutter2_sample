import 'package:flutter/material.dart';

import '../../models/issue.dart';
import '../../utils/color_converter.dart';

class IssueTypeChip extends StatelessWidget {
  final IssueType issueType;

  const IssueTypeChip(this.issueType);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        color: ColorConverter.fromString(issueType.color),
      ),
      child: Text(
        issueType.name,
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
