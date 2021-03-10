import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter2_sample/backlog_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'activities.dart';
import 'const.dart';
import 'env_vars.dart';
import 'models/project.dart';
import 'provider/credential_info.dart';
import 'provider/selected_project.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CredentialInfo>(
      create: (_) => CredentialInfo(),
      child: MaterialApp(
        title: 'Backlog Alternate',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.mPlus1pTextTheme(),
        ),
        home: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final _userController = TextEditingController(text: EnvVars.spaceName);
  final _passwordController = TextEditingController(text: EnvVars.apiKey);

  Future<bool> login(String space, String apiKey) async {
    var client = http.Client();

    var url = Uri.https(space, SPACE_INFO, {
      'apiKey': apiKey,
    });

    final response = await client.get(url);
    final responseBody = utf8.decode(response.bodyBytes);
    if (response.statusCode != 200) {
      print(responseBody);
      return false;
    } else {
      print(responseBody);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width;
    if (MediaQuery.of(context).size.width > 500) {
      width = 500;
    } else {
      width = MediaQuery.of(context).size.width;
    }
    return Scaffold(
      body: Center(
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(vertical: 48.0),
          child: AutofillGroup(
            child: Column(
              children: [
                Spacer(),
                Text("Welcome to Backlog Alternate with Flutter2"),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      width: 100,
                      child: Text("スペース"),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _userController,
                        autofillHints: [AutofillHints.username],
                        obscureText: false,
                        onSaved: (value) => print("スペース: " + value!),
                      ),
                    ),
                  ],
                ),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      width: 100,
                      child: Text("APIキー"),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        autofillHints: [AutofillHints.password],
                        obscureText: true,
                        onSaved: (value) => print("APIキー: " + value!),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final pass = _passwordController.value.text;
                      final user = _userController.value.text;
                      print("Login pressed:" + user + ":" + pass);
                      final isValid = await login(user, pass);
                      if (isValid) {
                        final credentialInfo =
                            Provider.of<CredentialInfo>(context, listen: false);
                        credentialInfo.apiKey = pass;
                        credentialInfo.space = user;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) {
                              return MyHomePage(
                                title: 'Backlog Alternate with Flutter2',
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Text("ログイン"),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
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
    final a = Provider.of<CredentialInfo>(context);
    print("MyHomeApp: " + a.space! + "/" + a.apiKey!);

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
            children: [
              RecentActivityList(),
              Text("かだいたち"),
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
    return FutureBuilder<List<Activity>>(
      future: backlogApiClient.fetchActivities(context, http.Client()),
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
    return Scrollbar(
      child: ListView.separated(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return ActivitySimple(filtered[index]);
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
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
    return ListTile(
      title: Text(content),
      leading: Image.network(userIconUri.toString()),
      subtitle: Text(_activity.project.name),
      trailing: Text(_activity.createdUser.name),
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
    return FutureBuilder<List<Project>>(
      future: fetchProjects(context, http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        final selectedProject =
            Provider.of<SelectedProject>(context, listen: true);

        return snapshot.hasData
            ? Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: DropdownButton<Project>(
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

List<Project> parseProjects(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Project>((json) => Project.fromJson(json)).toList();
}

Future<List<Project>> fetchProjects(
    BuildContext context, http.Client client) async {
  final credentialInfo = Provider.of<CredentialInfo>(context);
  final apiKey = credentialInfo.apiKey;
  final space = credentialInfo.space!;
  var url = Uri.https(space, PROJECTS, {
    'apiKey': apiKey,
    'archived': false.toString(),
  });

  final response = await client.get(url);
  final responseBody = utf8.decode(response.bodyBytes);
  return compute(parseProjects, responseBody);
}
