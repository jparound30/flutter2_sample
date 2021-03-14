import 'user.dart';

class IssueType {
  final String name;
  final String color;

  IssueType({
    required this.name,
    required this.color,
  });

  factory IssueType.fromJson(Map<String, dynamic> json) {
    return IssueType(
      name: json['name'],
      color: json['color'],
    );
  }
}

class Issue {
  final int id;
  final int projectId;
  final String issueKey;
  final int keyId;
  final IssueType issueType;
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
    required this.issueKey,
    required this.keyId,
    required this.issueType,
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
      issueKey: json['issueKey'],
      keyId: json['keyId'],
      issueType: IssueType.fromJson(json['issueType']),
      summary: json['summary'],
      description: json['description'],
      createdUser: User.fromJson(json['createdUser']),
      updatedUser: User.fromJson(json['updatedUser']),
      created: json['created'],
      updated: json['updated'],
    );
  }
}
