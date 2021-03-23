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
