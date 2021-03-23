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
