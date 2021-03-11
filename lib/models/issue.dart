import 'user.dart';

class Issue {
  final int id;
  final int projectId;
  final String summary;
  final String description;

  // TODO add more fields
  final User createdUser;
  final User? updatedUser;

  final String? _createdStr;
  final String? _updatedStr;

  DateTime? get created {
    if (_createdStr != null) {
      return DateTime.parse(_createdStr!).toLocal();
    } else {
      return null;
    }
  }

  DateTime? get updated {
    if (_updatedStr != null) {
      return DateTime.parse(_updatedStr!).toLocal();
    } else {
      return null;
    }
  }

  Issue({
    required this.id,
    required this.projectId,
    required this.summary,
    required this.description,
    required this.createdUser,
    this.updatedUser,
    String? created,
    String? updated,
  })  : _createdStr = created,
        _updatedStr = updated;

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      projectId: json['projectId'],
      summary: json['summary'],
      description: json['description'],
      createdUser: User.fromJson(json['createdUser']),
      updatedUser: User.fromJson(json['updatedUser']),
      created: json['created'],
      updated: json['updated'],
    );
  }
}
