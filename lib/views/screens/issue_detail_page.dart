import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/issue.dart';
import '../components/issue_type_chip.dart';
import '../components/status_chip.dart';

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

  /// 未設定
  final _notSetText = Text(
    "未設定",
    style: TextStyle(
      color: Colors.grey.shade400,
    ),
  );

  IssueDetail({required this.issue});

  @override
  Widget build(BuildContext context) {
    var dateFormatYmd = DateFormat('yyyy/MM/dd', 'ja');
    var dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja');

    var created = dateFormat.format(issue.created!);

    final category = issue.category?.map((e) => e.name).toList().join(",");
    final milestone = issue.milestones?.map((e) => e.name).toList().join(",");
    final version = issue.versions?.map((e) => e.name).toList().join(",");

    return Container(
      constraints: BoxConstraints.expand(),
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IssueTypeChip(issue.issueType),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue.createdUser.name),
                      Text(created + " 登録"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("開始日"),
                      if (issue.startDate != null)
                        Text(dateFormatYmd.format(issue.startDate!))
                      else
                        _notSetText,
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("期限日"),
                      if (issue.dueDate != null)
                        Text(dateFormatYmd.format(issue.dueDate!))
                      else
                        _notSetText,
                    ],
                  ),
                  StatusChip(issue.status),
                ],
              ),
              Container(
                width: double.infinity,
                child: Text(
                  this.issue.summary,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      BacklogMarkdownRender(markdown: issue.description),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("優先度"),
                                ),
                                Text(issue.priority.name),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("担当者"),
                                ),
                                if (issue.assignee != null)
                                  Text(issue.assignee!.name)
                                else
                                  _notSetText,
                              ],
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("カテゴリ"),
                                ),
                                if (category != null && category.length != 0)
                                  Text(category)
                                else
                                  _notSetText,
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("マイルストーン"),
                                ),
                                if (milestone != null && milestone.length != 0)
                                  Text(milestone)
                                else
                                  _notSetText,
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("発生バージョン"),
                                ),
                                if (version != null && version.length != 0)
                                  Text(version)
                                else
                                  _notSetText,
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("予定時間"),
                                ),
                                if (issue.estimatedHours != null)
                                  Text(issue.estimatedHours.toString())
                                else
                                  _notSetText,
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("実績時間"),
                                ),
                                if (issue.actualHours != null)
                                  Text(issue.actualHours.toString())
                                else
                                  _notSetText,
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text("完了理由"),
                                ),
                                if (issue.resolution != null)
                                  Text(issue.resolution!.name)
                                else
                                  _notSetText,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
      child: Text(this.markdown),
    );
  }
}
