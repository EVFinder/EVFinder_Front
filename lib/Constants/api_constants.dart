class ApiConstants {
  //본인 서버 주소 사용
  static const String baseUrl = 'http://100.100.105.46:8080';
  static const String authApiBaseUrl = 'http://100.100.105.46:8080/auth';
  static const String evApiBaseUrl = '$baseUrl/api/ev';
  static const String favoriteApiBaseUrl = '$baseUrl/api/favorite';
  static const String keywordForSearch = '$baseUrl/api/keyword';
  static const String addressApiBaseUrl = '$baseUrl/api/ev/coord2addr?';
}
