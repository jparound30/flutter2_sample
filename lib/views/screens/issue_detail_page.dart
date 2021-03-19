import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/issue.dart';

class IssueDetailPage extends StatelessWidget {
  IssueDetailPage({Key? key, required issue})
      : _issue = issue,
        super(key: key);

  final Issue _issue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _issue.summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [],
        centerTitle: false,
      ),
      body: Text(_issue.description),
    );
  }
}
