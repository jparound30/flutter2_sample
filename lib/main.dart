import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'activities.dart';
import 'const.dart';
import 'env_vars.dart';
import 'models/project.dart';
import 'provider/selected_project.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backlog Alternate',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.mPlus1pTextTheme(),
      ),
      home: MyHomePage(title: 'Backlog Alternate with Flutter2'),
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return ChangeNotifierProvider<SelectedProject>(
      create: (_) => SelectedProject(),
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(title),
          actions: [MyStatefulWidget()],
          centerTitle: false,
        ),
        body: RecentActivityList(),
      ),
    );
  }
}

class RecentActivityList extends StatelessWidget {
  RecentActivityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Activity>>(
      future: fetchActivities(http.Client()),
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
    Uri userIconUri = Uri.https(
        EnvVars.spaceName,
        "/api/v2/users/" + _activity.createdUser.id.toString() + "/icon",
        {'apiKey': EnvVars.apiKey});
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

// This is the type used by the popup menu below.
enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Project>>(
      future: fetchProjects(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        final selectedProject = Provider.of<SelectedProject>(context, listen: true);

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

Future<List<Project>> fetchProjects(http.Client client) async {
  var url = Uri.https(EnvVars.spaceName, PROJECTS, {
    'apiKey': EnvVars.apiKey,
    'archived': false.toString(),
  });

  final response = await client.get(url);
  final responseBody = utf8.decode(response.bodyBytes);
  return compute(parseProjects, responseBody);
}
