class CommunityCategory {
  final String categoryId;
  final String name;
  final String description;

  CommunityCategory({required this.categoryId, required this.name, required this.description});

  factory CommunityCategory.fromJson(Map<String, dynamic> json) {
    return CommunityCategory(categoryId: json['categoryId'], name: json['name'], description: json['description']);
  }
}
