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

