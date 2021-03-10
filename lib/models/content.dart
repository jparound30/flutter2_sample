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
