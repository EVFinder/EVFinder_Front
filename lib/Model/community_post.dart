class CommunityPost {
  final String postId;
  final String categoryId;
  final String title;
  final String content;
  final String uid;
  final String authorName;
  final int views;
  final int likes;
  final String createdAt;
  final String updatedAt;
  final bool owner;

  CommunityPost({
    required this.postId,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.uid,
    required this.authorName,
    required this.views,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      postId: json['postId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      uid: json['uid'] ?? '',
      authorName: json['authorName'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      owner: json['owner'] ?? false,
    );
  }
}
