import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'backlog_api.dart';
import 'env_vars.dart';
import 'home_page.dart';
import 'issuesList.dart';
import 'login.dart';
import 'models/activity.dart';
import 'models/project.dart';
import 'models/space.dart';
import 'myapp.dart';
import 'provider/credential_info.dart';
import 'provider/selected_project.dart';

void main() {
  Intl.defaultLocale = 'ja_JP';
  initializeDateFormatting('ja_JP', null).then((_) {
    runApp(MyApp());
  });
}

class EntryScreen extends StatefulWidget {
  @override
  EntryScreenState createState() {
    return EntryScreenState();
  }
}

class EntryScreenState extends State<EntryScreen> {
  final BacklogApiClient apiClient = BacklogApiClient();

  Future<Space>? test(CredentialInfo info) async {
    if (info.apiKey!.isNotEmpty && info.space!.isNotEmpty) {
      return apiClient.login(info.space!, info.apiKey!);
    } else {
      return Future<Space>.error("no apikey / space");
    }
  }

  _startTransition(Space space) async {
    final d = new Duration(seconds: 0);

    final _transition = () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return HomePage(
              title: '[' + space.name + ']',
            );
          },
        ),
      );
    };

    return Timer(d, _transition);
  }

  @override
  Widget build(BuildContext context) {
    var credentialInfo = Provider.of<CredentialInfo>(context);

    if (credentialInfo.apiKey != null) {
      print("CREDENTIALS EXISTS. CHECK WHETHER VALID OR NOT!");
      return FutureBuilder(
        future: test(credentialInfo),
        builder: (context, AsyncSnapshot<Space> snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (snapshot.hasData) {
            print('SHOW RecentActivity');
            _startTransition(snapshot.data!);
            return Center(child: CircularProgressIndicator());
          } else {
            print('SHOW LoginPage');
            return LoginPage();
          }
        },
      );
    } else {
      print("NO CREDENTIAL");
      return LoginPage();
    }
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
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
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: DropdownButton<Project>(
                  hint: Text("プロジェクトを選択"),
                  value: selectedProject.project,
                  icon: Icon(Icons.arrow_downward),
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
            : Center(child: CircularProgressIndicator());
      },
    );
  }
}
