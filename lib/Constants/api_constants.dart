class ApiConstants {
  //본인 서버 주소 사용
  static const String ip = '100.100.108.96'; // IP 만 바꿔주면 됨
  static const String baseUrl = 'http://$ip:8080';

  static const String authApiBaseUrl = 'http://$ip:8080/auth';
  static const String evApiBaseUrl = '$baseUrl/api/charger/';
  static const String favoriteApiBaseUrl = '$baseUrl/api/favorite';
  static const String weatherApiBaseUrl = '$baseUrl/weather';
  static const String keywordPlaceApiUrl = '$baseUrl/place/placelist';
  static const String chargerbnbApiUrl = '$baseUrl/share';
  static const String reviewBaseUrl = '$baseUrl/api/review';
  static const String reservApiBaseUrl = '$baseUrl/reserve';
  static const String coorToAddr = '$baseUrl/place/address';




// static const String keywordForSearch = '$baseUrl/api/keyword';
  // static const String addressApiBaseUrl = '$baseUrl/api/ev/coord2addr?';
}
