class CommunityPost {
  final String postId;
  final String title;
  final String content;
  final String uid;
  final String authorName;
  final int views;
  final int likes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOwner;

  CommunityPost({
    required this.postId,
    required this.title,
    required this.content,
    required this.uid,
    required this.authorName,
    required this.views,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
    required this.isOwner,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      postId: json['postId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      uid: json['uid'] ?? '',
      authorName: json['authorName'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      createdAt: json['createdAt'] ?? DateTime.now(),
      updatedAt: json['updatedAt'] ?? DateTime.now(),
      isOwner: json['isOwner'] ?? false,
    );
  }
}