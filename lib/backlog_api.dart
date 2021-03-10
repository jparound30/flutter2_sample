// A function that converts a response body into a List<Photo>.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'activities.dart';
import 'const.dart';
import 'models/project.dart';
import 'provider/credential_info.dart';

class BacklogApiClient {
  final http.Client _client;

  BacklogApiClient() : _client = http.Client();

  List<Activity> _parseActivities(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Activity>((json) => Activity.fromJson(json)).toList();
  }

  Future<List<Activity>> fetchActivities(
      BuildContext context) async {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    var url = Uri.https(
        space, SPACE_ACTIVITIES, {'apiKey': apiKey, 'count': 100.toString()});

    final response = await _client.get(url);
    final responseBody = utf8.decode(response.bodyBytes);
    return compute(_parseActivities, responseBody);
  }

  List<Project> _parseProjects(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Project>((json) => Project.fromJson(json)).toList();
  }

  Future<List<Project>> fetchProjects(
      BuildContext context) async {
    final credentialInfo = Provider.of<CredentialInfo>(context);
    final apiKey = credentialInfo.apiKey;
    final space = credentialInfo.space!;
    var url = Uri.https(space, PROJECTS, {
      'apiKey': apiKey,
      'archived': false.toString(),
    });

    final response = await _client.get(url);
    final responseBody = utf8.decode(response.bodyBytes);
    return compute(_parseProjects, responseBody);
  }
}
