import 'category.dart';
import 'user.dart';

/// 課題のフィールド列挙型（ソートキー用）
enum IssueField {
  /// 種類
  issueType,

  /// ID
  id,

  /// カテゴリー
  category,

  /// 発生バージョン
  version,

  /// マイルストーン
  milestone,

  /// 要約
  summary,

  /// 状態
  status,

  /// 優先度
  priority,

  /// 添付ファイル
  attachment,

  /// 共有ファイル
  sharedFile,

  /// 作成日時
  created,

  /// 作成者
  createdUser,

  /// 更新日時
  updated,

  /// 更新者
  updatedUser,

  /// 担当者
  assignee,

  /// 開始日
  startDate,

  /// 期限日
  dueDate,

  /// 予定時間
  estimatedHours,

  /// 実績時間
  actualHours,

  /// 子課題
  childIssue,
  // customField_${id},
}

abstract class EnumHelper<T> {
  List<T> values();

  Map<T, String> maps();

  T valueOf(String value) {
    return values().firstWhere((e) => name(e) == value,
        orElse: () => throw new Exception("INVALID ENUM"));
  }

  String name(T value) {
    return value.toString().split('.').last;
  }

  String description(T value) {
    return maps()[value]!;
  }
}

class IssueFieldEnumHelper extends EnumHelper<IssueField> {
  @override
  List<IssueField> values() => IssueField.values;

  @override
  Map<IssueField, String> maps() {
    final ret = Map<IssueField, String>();
    ret[IssueField.issueType] = "種類";
    ret[IssueField.id] = "キー";
    ret[IssueField.category] = "カテゴリー";
    ret[IssueField.version] = "発生バージョン";
    ret[IssueField.milestone] = "マイルストーン";
    ret[IssueField.summary] = "要約";
    ret[IssueField.status] = "状態";
    ret[IssueField.priority] = "優先度";
    ret[IssueField.attachment] = "添付ファイル";
    ret[IssueField.sharedFile] = "共有ファイル";
    ret[IssueField.created] = "作成日時";
    ret[IssueField.createdUser] = "作成者";
    ret[IssueField.updated] = "更新日時";
    ret[IssueField.updatedUser] = "更新者";
    ret[IssueField.assignee] = "担当者";
    ret[IssueField.startDate] = "開始日";
    ret[IssueField.dueDate] = "期限日";
    ret[IssueField.estimatedHours] = "予定時間";
    ret[IssueField.actualHours] = "実績時間";
    ret[IssueField.childIssue] = "子課題";
    return ret;
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
  final List<Category>? category;
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
    this.category,
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
      category: json['category'] != null
          ? json['category']
              .cast<Map<String, dynamic>>()
              .map<Category>((category) => Category.fromJson(category))
              .toList()
          : null,
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
