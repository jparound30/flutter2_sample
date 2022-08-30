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

  @override
  bool operator ==(Object other) {
    return (other is Project) && (id == other.id);
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
