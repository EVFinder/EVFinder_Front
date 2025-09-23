import 'package:evfinder_front/Model/ev_charger_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/map_controller.dart';
import '../../Model/ev_charger.dart';

class ChargerDetailCard extends GetView<MapController> {
  const ChargerDetailCard({
    super.key,
    required this.charger,
    required this.isFavorite,
    // required this.uid,
    this.onFavoriteToggle,
  });

  final EvCharger charger;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    // final charger = charger;
    // final chargerTypeText = convertChargerType(charger.evchargerDetail[0].type);
    // final chargerStateColor = getStatusColor(int.parse(charger.evchargerDetail[0].status));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width - 25,
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 이름, 주소, 즐겨찾기 버튼
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Text(
                          charger.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Text(
                          charger.addr,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    // onPressed: _isProcessing ? null : _toggleFavorite, // 처리 중이면 비활성화
                    onPressed: () {}, // 처리 중이면 비활성화
                    icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: Colors.yellow),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 하단 상태
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(5)),
              width: MediaQuery.of(context).size.width,
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 20, right: 16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          // CircleAvatar(radius: 6, backgroundColor: chargerStateColor),
                          const SizedBox(width: 8),
                          // Flexible(child: Text(chargerTypeText, style: const TextStyle(fontWeight: FontWeight.bold))),
                          const SizedBox(width: 8),
                          // Flexible(
                          //   child: Text(
                          //     charger.evchargerDetail[0].powerType,
                          //     overflow: TextOverflow.ellipsis,
                          //     style: const TextStyle(fontSize: 12, color: Colors.grey),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${charger.evchargerDetail.where((detail) => detail.status == '2').length}", style: TextStyle(fontSize: 20, color: Colors.green)),
                            Text("/"),
                            Text("${charger.evchargerDetail.length}", style: TextStyle(fontSize: 20, color: Colors.blue)),
                          ],
                        ),
                        Text("충전가능", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        // Text(_getAvailabilityText(int.parse(charger.evchargerDetail[0].status)), style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
