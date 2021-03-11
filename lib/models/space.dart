class Space {
  final String spaceKey;
  final String name;
  final int? ownerId;
  final String? lang;
  final String? timezone;
  final String? reportSendTime;
  final String? textFormattingRule;
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

  Space({
    required this.spaceKey,
    required this.name,
    this.ownerId,
    this.lang,
    this.timezone,
    this.reportSendTime,
    this.textFormattingRule,
    String? created,
    String? updated,
  })  : _createdStr = created,
        _updatedStr = updated;

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      spaceKey: json['spaceKey'],
      name: json['name'],
      ownerId: json['ownId'],
      lang: json['lang'],
      timezone: json['timezone'],
      reportSendTime: json['reportSendTime'],
      textFormattingRule: json['textFormattingRule'],
      created: json['created'],
      updated: json['updated'],
    );
  }
}
