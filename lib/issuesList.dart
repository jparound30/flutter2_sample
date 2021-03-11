import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'backlog_api.dart';
import 'models/issue.dart';
import 'provider/credential_info.dart';
import 'provider/selected_project.dart';

class IssueList extends StatelessWidget {
  IssueList({Key? key}) : super(key: key);
  final backlogApiClient = BacklogApiClient();

  @override
  Widget build(BuildContext context) {
    final selectedProject = Provider.of<SelectedProject>(context, listen: true);
    if (selectedProject.project == null) {
      return Center(child: Text("プロジェクトを選択してください"));
    }
    return FutureBuilder<List<Issue>>(
      future: backlogApiClient.fetchIssues(
        context: context,
        project: selectedProject.project,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? IssueListView(issues: snapshot.data!)
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}

class IssueListView extends StatelessWidget {
  final List<Issue> issues;

  IssueListView({Key? key, required this.issues}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scrollbar(
        child: ListView.separated(
          itemCount: issues.length,
          itemBuilder: (context, index) {
            return IssueSimple(issues[index]);
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ),
      ),
    );
  }
}

class IssueSimple extends StatelessWidget {
  final Issue _issue;

  IssueSimple(this._issue);

  @override
  Widget build(BuildContext context) {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    Uri userIconUri = Uri.https(
        space,
        "/api/v2/users/" + _issue.createdUser.id.toString() + "/icon",
        {'apiKey': apiKey});
    var dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja');
    return ListTile(
      title: Text(
        _issue.summary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Image.network(userIconUri.toString()),
      subtitle: Text(
        _issue.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        children: [
          if (_issue.updated != null)
            Text(dateFormat.format(_issue.updated!))
          else if (_issue.created != null)
            Text(dateFormat.format(_issue.created!)),
          Text(_issue.createdUser.name),
        ],
      ),
    );
  }
}
