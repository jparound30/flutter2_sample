import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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
          _issue.issueKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [],
        centerTitle: false,
      ),
      body: IssueDetail(
        issue: _issue,
      ),
    );
  }
}

class IssueDetail extends StatelessWidget {
  final Issue issue;

  IssueDetail({required this.issue});

  @override
  Widget build(BuildContext context) {
    var dateFormatYmd = DateFormat('yyyy/MM/dd', 'ja');

    var startDate = dateFormatYmd.format(issue.startDate!);
    var dueDate = issue.dueDate != null ? dateFormatYmd.format(issue.dueDate!) : "未設定";

    return Container(
      constraints: BoxConstraints.expand(),
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Text(issue.issueType.name), // TODO カラーなど
              Text(issue.createdUser.name), // TODO
              Text(startDate), // TODO
              Text(dueDate), // TODO
              Text(issue.status.name), // TODO カラーなど
              Container(
                width: double.infinity,
                child: Card(
                  child: Text(this.issue.summary),
                ),
              ),
              BacklogMarkdownRender(markdown: issue.description),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Text(issue.priority.name)),
                  Expanded(
                      child: Text(
                          issue.assignee != null ? issue.assignee!.name : ""))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Text("TODO カテゴリ")), // TODO
                  Expanded(child: Text("TODO マイルストーン")), // TODO
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Text("TODO 発生バージョン")), // TODO
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Text(issue.estimatedHours.toString())), // TODO
                  Expanded(child: Text(issue.actualHours.toString())), // TODO
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Text("TODO 完了理由")), // TODO
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BacklogMarkdownRender extends StatelessWidget {
  final String markdown;

  BacklogMarkdownRender({
    required this.markdown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        child: Text(this.markdown),
      ),
    );
  }
}
