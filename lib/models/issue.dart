class Issue {
  final int id;
  final String summary;
  final String description;
  // TODO add more fields

  Issue({required this.id, required this.summary, required this.description});

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
        id: json['id'],
        summary: json['summary'],
        description: json['description']);
  }
}
