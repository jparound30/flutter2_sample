import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter2_sample/const.dart';
import 'package:flutter2_sample/env_vars.dart';
import 'package:http/http.dart' as http;

class Project {
  final int id;
  final String projectKey;
  final String name;
  final bool? chartEnabled;
  final bool? subtaskingEnabled;
  final bool? projectLeaderCanEditProjectLeader;

  // final String? textFormattingRule;
  final bool? archived;
  final int? displayOrder;

  Project(
      {required this.id,
      required this.projectKey,
      required this.name,
      this.chartEnabled,
      this.subtaskingEnabled,
      this.projectLeaderCanEditProjectLeader,
      // this.textFormattingRule,
      this.archived,
      this.displayOrder});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
        id: json['id'] as int,
        projectKey: json['projectKey'] as String,
        name: json['name'] as String,
        chartEnabled: json['chartEnabled'] as bool?,
        subtaskingEnabled: json['subtaskingEnabled'] as bool?,
        projectLeaderCanEditProjectLeader:
            json['projectLeaderCanEditProjectLeader'] as bool?,
        // textFormattingRule: json['textFormattingRule'] as String,
        archived: json['archived'] as bool?,
        displayOrder: json['displayOrder'] as int?);
  }

  bool operator==(Object other) {
    return (other is Project) && (id == other.id);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

}

class Content {
  final int id;
  final int? keyId;
  final String? summary;
  final String? description;

  Content(this.id, this.keyId, this.summary, this.description);

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(json['id'] as int, json['key_id'] as int?,
        json['summary'] as String?, json['description'] as String?);
  }
}

class Notification {
  final int id;

  Notification(this.id);
}

class User {
  final int id;
  final String? userId;
  final String name;
  final int roleType;
  final String? lang;
  final String? mailAddress;

  User(
      {required this.id,
      this.userId,
      required this.name,
      required this.roleType,
      this.lang,
      this.mailAddress});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        userId: json['userId'] as String?,
        name: json['name'] as String,
        roleType: json['roleType'] as int,
        lang: json['lang'] as String?,
        mailAddress: json['json'] as String?);
  }
}

class Activity {
  final int id;
  final Project project;
  final int type;
  final Content? content;
  final Notification? notification;
  final User createdUser;

  Activity(this.type,
      {required this.id,
      required this.project,
      this.content,
      this.notification,
      required this.createdUser});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(json['type'] as int,
        id: json['id'],
        project: Project.fromJson(json['project']),
        content: Content.fromJson(json['content']),
        createdUser: User.fromJson(json['createdUser']));
  }
}

// A function that converts a response body into a List<Photo>.
List<Activity> parseActivities(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Activity>((json) => Activity.fromJson(json)).toList();
}

Future<List<Activity>> fetchActivities(http.Client client) async {
  var url = Uri.https(EnvVars.spaceName, SPACE_ACTIVITIES, {
    'apiKey': EnvVars.apiKey,
    'count': 100.toString()
  });

  final response = await client.get(url);
  final responseBody = utf8.decode(response.bodyBytes);
  return compute(parseActivities, responseBody);
}
