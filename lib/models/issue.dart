import 'user.dart';

class Category {
  final int id;
  final String name;
  final int displayOrder;

  Category({
    required this.id,
    required this.name,
    required this.displayOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      displayOrder: json['displayOrder'],
    );
  }
}

class MilestoneVersion {
  final int id;
  final int projectId;
  final String name;
  final String? description;
  final String? _startDateStr;
  final String? _releaseDueDateStr;
  final bool archived;
  final int displayOrder;

  DateTime? get startDate {
    if (_startDateStr != null) {
      return DateTime.parse(_startDateStr!).toLocal();
    } else {
      return null;
    }
  }

  DateTime? get releaseDueDate {
    if (_releaseDueDateStr != null) {
      return DateTime.parse(_releaseDueDateStr!).toLocal();
    } else {
      return null;
    }
  }

  MilestoneVersion({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    String? startDate,
    String? releaseDueDate,
    required this.archived,
    required this.displayOrder,
  })   : _startDateStr = startDate,
        _releaseDueDateStr = releaseDueDate;

  factory MilestoneVersion.fromJson(Map<String, dynamic> json) {
    return MilestoneVersion(
      id: json['id'],
      projectId: json['projectId'],
      name: json['name'],
      description: json['description'],
      startDate: json['startDate'],
      releaseDueDate: json['releaseDueDate'],
      archived: json['archived'],
      displayOrder: json['displayOrder'],
    );
  }
}

class Resolution {
  final int id;
  final String name;

  Resolution({
    required this.id,
    required this.name,
  });

  factory Resolution.fromJson(Map<String, dynamic> json) {
    return Resolution(
      id: json['id'],
      name: json['name'],
    );
  }
}

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

  final Resolution? resolution;

  final Priority priority;
  final Status status;
  final User? assignee;

  final List<MilestoneVersion>? versions;
  final List<MilestoneVersion>? milestones;
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
    this.resolution,
    required this.priority,
    required this.status,
    this.assignee,
    this.versions,
    this.milestones,
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
    double? esHour;
    if (json['estimateHours'] != null) {
      if (json['estimateHours'] is int) {
        int t = json['estimateHours'];
        esHour = t.toDouble();
      } else {
        esHour = json['estimateHours'];
      }
    }
    double? acHours;
    if (json['actualHours'] != null) {
      if (json['actualHours'] is int) {
        int t = json['actualHours'];
        esHour = t.toDouble();
      } else {
        esHour = json['actualHours'];
      }
    }
    return Issue(
      id: json['id'],
      projectId: json['projectId'],
      issueKey: json['issueKey'],
      keyId: json['keyId'],
      issueType: IssueType.fromJson(json['issueType']),
      summary: json['summary'],
      description: json['description'],
      resolution: json['resolution'] != null
          ? Resolution.fromJson(json['resolution'])
          : null,
      priority: Priority.fromJson(json['priority']),
      status: Status.fromJson(json['status']),
      assignee: assignee,
      versions: json['versions'] != null
          ? json['versions']
              .cast<Map<String, dynamic>>()
              .map<MilestoneVersion>(
                  (versions) => MilestoneVersion.fromJson(versions))
              .toList()
          : null,
      milestones: json['milestone'] != null
          ? json['milestone']
              .cast<Map<String, dynamic>>()
              .map<MilestoneVersion>(
                  (versions) => MilestoneVersion.fromJson(versions))
              .toList()
          : null,
      startDate: json['startDate'],
      dueDate: json['dueDate'],
      estimatedHours: esHour,
      actualHours: acHours,
      createdUser: User.fromJson(json['createdUser']),
      updatedUser: User.fromJson(json['updatedUser']),
      created: json['created'],
      updated: json['updated'],
    );
  }
}
