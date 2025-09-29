class CommunityComment {
  final String commentId;
  final String? parentId; // nullable이어야 함
  final String content;
  final String uid;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool owner;

  CommunityComment({
    required this.commentId,
    required this.content,
    required this.uid,
    required this.authorName,
    required this.parentId,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      commentId: json['commentId'] ?? '',
      parentId: json['parentId'],
      // null일 수 있음
      content: json['content'] ?? '',
      uid: json['uid'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      owner: json['owner'] ?? false,
    );
  }

  // 날짜 문자열을 DateTime으로 변환하는 헬퍼 메서드
  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString == null || dateString == '') {
      return DateTime.now(); // 기본값
    }

    try {
      if (dateString is String) {
        return DateTime.parse(dateString);
      } else if (dateString is DateTime) {
        return dateString;
      } else {
        return DateTime.now();
      }
    } catch (e) {
      print('[ERROR] 날짜 파싱 실패: $dateString, 에러: $e');
      return DateTime.now(); // 파싱 실패 시 현재 시간 반환
    }
  }

  CommunityComment copyWith({String? commentId, String? parentId, String? content, String? uid, String? authorName, DateTime? createdAt, DateTime? updatedAt, bool? owner}) {
    return CommunityComment(
      commentId: commentId ?? this.commentId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      uid: uid ?? this.uid,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      owner: owner ?? this.owner,
    );
  }
}
