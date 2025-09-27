class TimeUtils {
  static String getTimeAgo(String createdAt) {
    try {
      // ISO 8601 형식 파싱
      DateTime createdTime = DateTime.parse(createdAt);
      DateTime now = DateTime.now();

      // 시간 차이 계산
      Duration difference = now.difference(createdTime);

      int seconds = difference.inSeconds;
      int minutes = difference.inMinutes;
      int hours = difference.inHours;
      int days = difference.inDays;

      if (seconds < 60) {
        return '방금 전';
      } else if (minutes < 60) {
        return '${minutes}분 전';
      } else if (hours < 24) {
        return '${hours}시간 전';
      } else if (days < 7) {
        return '${days}일 전';
      } else if (days < 30) {
        int weeks = (days / 7).floor();
        return '${weeks}주 전';
      } else if (days < 365) {
        int months = (days / 30).floor();
        return '${months}개월 전';
      } else {
        int years = (days / 365).floor();
        return '${years}년 전';
      }
    } catch (e) {
      print('[ERROR] 시간 파싱 오류: $e');
      return '알 수 없음';
    }
  }
}
