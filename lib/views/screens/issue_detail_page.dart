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
                        Text("未設定",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            )),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("期限日"),
                      if (issue.dueDate != null)
                        Text(dateFormatYmd.format(issue.dueDate!))
                      else
                        Text("未設定",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                            )),
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
                                Text(issue.assignee != null
                                    ? issue.assignee!.name
                                    : "未設定"),
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
                                Text(
                                  category != null && category.length != 0
                                      ? category
                                      : "未設定",
                                ),
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
                                Text(
                                  milestone != null && milestone.length != 0
                                      ? milestone
                                      : "未設定",
                                ),
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
                                Text(
                                  version != null && version.length != 0
                                      ? version
                                      : "未設定",
                                ),
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
                                Text(issue.estimatedHours?.toString() ?? "未設定"),
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
                                Text(issue.actualHours?.toString() ?? "未設定"),
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
                                Text(issue.resolution?.name ?? "未設定"),
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
