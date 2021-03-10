
import 'content.dart';
import 'notification.dart';
import 'project.dart';
import 'user.dart';

class Activity {
  final int id;
  final Project project;
  final int type;
  final Content? content;
  final Notification? notification;
  final User createdUser;
  final String _createdStr;

  Activity(
    this.type, {
    required this.id,
    required this.project,
    this.content,
    this.notification,
    required this.createdUser,
    required String createdStr,
  }) : _createdStr = createdStr;

  DateTime get created {
    return DateTime.parse(_createdStr).toLocal();
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      json['type'],
      id: json['id'],
      project: Project.fromJson(json['project']),
      content: Content.fromJson(json['content']),
      createdUser: User.fromJson(json['createdUser']),
      createdStr: json['created'],
    );
  }
}
