import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/issue.dart';
import 'models/project.dart';
import 'provider/credential_info.dart';
import 'provider/selected_project.dart';

class IssueList extends StatelessWidget {
  final List<Issue> issues;

  IssueList({Key? key, required this.issues}) : super(key: key);

  List<Issue> filteredByProject(Project? project) {
    if (project == null) {
      return [];
    }

    return issues
        .where((element) => element.projectId == project.id)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedProject = Provider.of<SelectedProject>(context);
    final filtered = filteredByProject(selectedProject.project);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scrollbar(
        child: ListView.separated(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return IssueSimple(filtered[index]);
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
