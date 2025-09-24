class EvChargerDetail {
  final String operationId;
  final String operationName;
  final String stationId;
  final String chargerId;
  final String type;
  final String status;
  final String powerType;
  final String chargingDateTime;
  final String updateDateTime;
  final String isFast;
  final String isAvailable;

  EvChargerDetail({
    required this.operationId,
    required this.operationName,
    required this.stationId,
    required this.chargerId,
    required this.type,
    required this.status,
    required this.powerType,
    required this.chargingDateTime,
    required this.updateDateTime,
    required this.isFast,
    required this.isAvailable,
  });

  factory EvChargerDetail.fromJson(Map<String, dynamic> json) {
    return EvChargerDetail(
      operationId: json['operationId'] ?? '',
      operationName: json['operationName'] ?? '',
      stationId: json['stationId'] ?? '',
      chargerId: json['chargerId'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      powerType: json['powerType'] ?? '',
      chargingDateTime: json['chargingDateTime'] ?? '',
      updateDateTime: json['updateDateTime'] ?? '',
      isFast: json['isFast'] ?? '',
      isAvailable: json['isAvailable'] ?? '',

    );
  }
}
