import 'package:flutter/material.dart';

import '../../color_converter.dart';
import '../../models/issue.dart';

class IssueTypeChip extends StatelessWidget {
  final IssueType issueType;

  IssueTypeChip(this.issueType);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        color: ColorConverter.fromString(issueType.color),
      ),
      child: Text(
        issueType.name,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
