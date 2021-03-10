class User {
  final int id;
  final String? userId;
  final String name;
  final int roleType;
  final String? lang;
  final String? mailAddress;

  User({
    required this.id,
    this.userId,
    required this.name,
    required this.roleType,
    this.lang,
    this.mailAddress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int,
        userId: json['userId'] as String?,
        name: json['name'] as String,
        roleType: json['roleType'] as int,
        lang: json['lang'] as String?,
        mailAddress: json['json'] as String?);
  }
}
