class ApiConstants {
  //본인 서버 주소 사용
  static const String ip = '192.168.0.110'; // IP 만 바꿔주면 됨
  static const String baseUrl = 'http://$ip:8080';
  static const String authApiBaseUrl = 'http://$ip:8080/auth';
  static const String evApiBaseUrl = '$baseUrl/api/charger/';
  static const String favoriteApiBaseUrl = '$baseUrl/api/favorite';
  static const String keywordForSearch = '$baseUrl/api/keyword';
  static const String addressApiBaseUrl = '$baseUrl/api/ev/coord2addr?';
}
