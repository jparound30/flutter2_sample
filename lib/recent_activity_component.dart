import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'backlog_api.dart';
import 'models/activity.dart';
import 'models/project.dart';
import 'provider/credential_info.dart';
import 'provider/selected_project.dart';

class RecentActivityList extends StatelessWidget {
  RecentActivityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backlogApiClient = BacklogApiClient();
    final credentialInfo = Provider.of<CredentialInfo>(context);
    return FutureBuilder<List<Activity>>(
      future: backlogApiClient.fetchActivities(credentialInfo),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? ActivityList(activities: snapshot.data!)
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}

class ActivityList extends StatelessWidget {
  final List<Activity> activities;

  ActivityList({Key? key, required this.activities}) : super(key: key);

  List<Activity> filteredByProject(Project? project) {
    if (project == null) {
      return [];
    }

    return activities
        .where((element) => element.project.id == project.id)
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
            return ActivitySimple(filtered[index]);
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ),
      ),
    );
  }
}

class ActivitySimple extends StatelessWidget {
  final Activity _activity;

  ActivitySimple(this._activity);

  @override
  Widget build(BuildContext context) {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    Uri userIconUri = Uri.https(
        space,
        "/api/v2/users/" + _activity.createdUser.id.toString() + "/icon",
        {'apiKey': apiKey});
    final String content;
    if (_activity.content!.summary != null) {
      content = _activity.content!.summary!;
    } else if (_activity.content!.description != null) {
      content = _activity.content!.description!;
    } else {
      content = "NODATA";
    }
    var dateFormat = DateFormat('yyyy/MM/dd HH:mm', 'ja');
    return ListTile(
      title: Text(
        content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Image.network(userIconUri.toString()),
      subtitle: Text(_activity.project.name),
      trailing: Column(
        children: [
          Text(dateFormat.format(_activity.created)),
          Text(_activity.createdUser.name),
        ],
      ),
    );
  }
}
