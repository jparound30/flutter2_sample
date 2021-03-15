import 'user.dart';

class Priority {
  final int id;
  final String name;

  Priority({
    required this.id,
    required this.name,
  });

  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Status {
  final int id;
  final int projectId;
  final String name;
  final String color;

  Status({
    required this.id,
    required this.projectId,
    required this.name,
    required this.color,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'],
      projectId: json['projectId'],
      name: json['name'],
      color: json['color'],
    );
  }
}

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

  final Priority priority;
  final Status status;
  final User? assignee;

  final String? _startDateStr;
  final String? _dueDateStr;

  DateTime? get startDate {
    if (_startDateStr != null) {
      return DateTime.parse(_startDateStr!).toLocal();
    } else {
      return null;
    }
  }

  DateTime? get dueDate {
    if (_dueDateStr != null) {
      return DateTime.parse(_dueDateStr!).toLocal();
    } else {
      return null;
    }
  }

  final double? estimatedHours;
  final double? actualHours;

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
    required this.priority,
    required this.status,
    this.assignee,
    String? startDate,
    String? dueDate,
    this.estimatedHours,
    this.actualHours,
    required this.createdUser,
    this.updatedUser,
    String? created,
    String? updated,
  })  : _startDateStr = startDate,
        _dueDateStr = dueDate,
        _createdStr = created,
        _updatedStr = updated;

  factory Issue.fromJson(Map<String, dynamic> json) {
    User? assignee;
    if (json['assignee'] != null) {
      assignee = User.fromJson(json['assignee']);
    }
    return Issue(
      id: json['id'],
      projectId: json['projectId'],
      issueKey: json['issueKey'],
      keyId: json['keyId'],
      issueType: IssueType.fromJson(json['issueType']),
      summary: json['summary'],
      description: json['description'],
      priority: Priority.fromJson(json['priority']),
      status: Status.fromJson(json['status']),
      assignee: assignee,
      startDate: json['startDate'],
      dueDate: json['dueDate'],
      estimatedHours: json['estimateHours'],
      actualHours: json['actualHours'],
      createdUser: User.fromJson(json['createdUser']),
      updatedUser: User.fromJson(json['updatedUser']),
      created: json['created'],
      updated: json['updated'],
    );
  }
}
