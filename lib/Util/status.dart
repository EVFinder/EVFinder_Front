import 'dart:ui';


String getStatusLabel(int stat) {
  switch (stat) {
    case 0: return '알수없음';
    case 1: return '통신이상';
    case 2: return '이용가능';
    case 3: return '충전중';
    case 4: return '운영중지';
    case 5: return '점검중';
    default: return '알수없음';
  }
}

Color getStatusColor(int stat) {
  switch (stat) {
    case 2:
      return const Color(0xFF059669); // 초록 (사용 가능)
    case 3:
      return const Color(0xFF2563EB); // 파랑 (충전 중)
    case 4:
    case 5:
      return const Color(0xFFDC2626); // 빨강 (중지, 점검)
    case 1:
      return const Color(0xFFF97316); // 주황 (통신이상)
    default:
      return const Color(0xFF9CA3AF); // 회색 (기타)
  }
}