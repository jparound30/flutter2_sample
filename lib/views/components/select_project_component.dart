import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../backlog_api.dart';
import '../../models/project.dart';
import '../../providers/credential_info.dart';
import '../../providers/selected_project.dart';

class SelectProjectDropdown extends StatefulWidget {
  const SelectProjectDropdown({Key? key}) : super(key: key);

  @override
  _SelectProjectDropdownState createState() => _SelectProjectDropdownState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _SelectProjectDropdownState extends State<SelectProjectDropdown> {
  @override
  Widget build(BuildContext context) {
    final backlogApiClient = BacklogApiClient();
    final credentialInfo = Provider.of<CredentialInfo>(context);

    return FutureBuilder<List<Project>>(
      future: backlogApiClient.fetchProjects(credentialInfo),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        final selectedProject =
        Provider.of<SelectedProject>(context, listen: true);

        return snapshot.hasData
            ? Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DropdownButton<Project>(
            hint: const Text("プロジェクトを選択"),
            value: selectedProject.project,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            underline: Container(
              height: 2,
              color: Colors.blueAccent.shade100,
            ),
            onChanged: (Project? newValue) {
              selectedProject.project = newValue;
            },
            items: snapshot.data!
                .map<DropdownMenuItem<Project>>((Project value) {
              return DropdownMenuItem<Project>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
        )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}
