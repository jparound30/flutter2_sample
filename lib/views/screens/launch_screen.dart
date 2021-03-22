import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../backlog_api.dart';
import 'home_page.dart';
import '../../login.dart';
import '../../models/space.dart';
import '../../providers/credential_info.dart';

class LaunchScreen extends StatefulWidget {
  @override
  EntryScreenState createState() {
    return EntryScreenState();
  }
}

class EntryScreenState extends State<LaunchScreen> {
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
