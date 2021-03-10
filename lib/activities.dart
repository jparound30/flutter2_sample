import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'const.dart';
import 'models/project.dart';
import 'provider/credential_info.dart';



class Content {
  final int? id;
  final int? keyId;
  final String? summary;
  final String? description;

  Content(this.id, this.keyId, this.summary, this.description);

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(json['id'] as int?, json['key_id'] as int?,
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

