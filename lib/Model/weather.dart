class Weather {
  final String main;
  final String description;
  final double temperature;
  final double feelsLike;
  final int humidity;

  //날씨 종류
  //Thunderstorm(천둥 번개), Drizzle(이슬비), Rain(비), Snow(눈), Atmosphere(대기 상태), Clear(맑음), Clouds(구름)

  Weather({required this.main, required this.description, required this.temperature, required this.feelsLike, required this.humidity});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      main: json['main'] ?? '',
      description: json['description'] ?? '',
      temperature: json['temperature'] ?? 0.0,
      feelsLike: json['feelsLike'] ?? 0.0,
      humidity: json['humidity'] ?? 0,
    );
  }
}
