import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'backlog_api.dart';
import 'env_vars.dart';
import 'issuesList.dart';
import 'login.dart';
import 'models/activity.dart';
import 'models/project.dart';
import 'models/space.dart';
import 'provider/credential_info.dart';
import 'provider/selected_project.dart';

void main() {
  Intl.defaultLocale = 'ja_JP';
  initializeDateFormatting('ja_JP', null).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // PaginatedDataTableのヘッダ行部分の背景色を設定
    var dataTableThemeData = ThemeData.dark().dataTableTheme.copyWith(
      headingRowColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.18);
        },
      ),
    );
    return ChangeNotifierProvider<CredentialInfo>(
      create: (_) {
        if (EnvVars.apiKey.isNotEmpty && EnvVars.spaceName.isNotEmpty) {
          return CredentialInfo(
              space: EnvVars.spaceName, apiKey: EnvVars.apiKey);
        }
        return CredentialInfo();
      },
      child: MaterialApp(
        title: 'Backlog Alternate',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,

          // textTheme: GoogleFonts.mPlus1pTextTheme(),
          textTheme: GoogleFonts.notoSansTextTheme(),
          dataTableTheme: dataTableThemeData,
        ),
        home: EntryScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
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
            return MyHomePage(
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

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return ChangeNotifierProvider<SelectedProject>(
      create: (_) => SelectedProject(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(title),
            actions: [MyStatefulWidget()],
            centerTitle: false,
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "最近の更新",
                ),
                Tab(
                  text: "課題",
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              RecentActivityList(),
              IssueList(),
            ],
          ),
        ),
      ),
    );
  }
}

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
