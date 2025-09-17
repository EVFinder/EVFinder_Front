import 'ev_charger_detail.dart';

class EvCharger {
  final String id;
  final String name;
  final String addr;
  final double lat;
  final double lon;
  final List<EvChargerDetail> evchargerDetail;

  EvCharger({required this.id, required this.name, required this.addr, required this.lat, required this.lon, required this.evchargerDetail});

  factory EvCharger.fromJson(Map<String, dynamic> json) {
    return EvCharger(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      addr: json['address'] ?? '',
      lat: json['lat'] ?? 0.0,
      lon: json['lon'] ?? 0.0,
      evchargerDetail: (json['evChargers'] as List<dynamic>?)?.map((item) => EvChargerDetail.fromJson(item as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
