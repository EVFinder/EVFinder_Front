import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:async';
import 'navigation_data.dart';

class NavigationMapWidget extends StatefulWidget {
  final NavigationData navigationData;
  final NLatLng? currentLocation;

  const NavigationMapWidget({Key? key, required this.navigationData, this.currentLocation}) : super(key: key);

  @override
  _NavigationMapWidgetState createState() => _NavigationMapWidgetState();
}

class _NavigationMapWidgetState extends State<NavigationMapWidget> {
  NaverMapController? _mapController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(NavigationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 현재 위치가 변경되면 마커 업데이트
    if (oldWidget.currentLocation != widget.currentLocation) {
      _updateCurrentLocationMarker();
      _updateCameraPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기본 위치 설정 (서울시청)
    NLatLng initialPosition = NLatLng(37.5665, 126.978);

    // 경로가 있으면 첫 번째 포인트 사용
    if (widget.navigationData.fullRoute?.isNotEmpty == true) {
      initialPosition = widget.navigationData.fullRoute!.first;
    }
    // 현재 위치가 있으면 현재 위치 사용
    else if (widget.currentLocation != null) {
      initialPosition = widget.currentLocation!;
    }

    return NaverMap(
      onMapReady: _onMapCreated,
      onCameraChange: _onCameraMove,
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: initialPosition,
          zoom: 15,
        ),
        locationButtonEnable: true,
        indoorEnable: true,
        mapType: NMapType.basic,
        activeLayerGroups: [NLayerGroup.building],
      ),
    );
  }

  void _onMapCreated(NaverMapController controller) {
    _mapController = controller;
    _initializeMap();
  }

  void _initializeMap() async {
    if (_mapController == null) return;

    try {
      // 경로 폴리라인 그리기
      await _drawRoute();

      // 마커들 설정
      await _setupMarkers();

      // 카메라를 경로에 맞게 조정
      _fitCameraToRoute();
    } catch (e) {
      print('🔥 지도 초기화 오류: $e');
    }
  }

  void _onCameraMove(NCameraUpdateReason reason, bool animated) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      print('Camera moved: $reason, animated: $animated');
    });
  }

  // 경로 폴리라인 그리기
  Future<void> _drawRoute() async {
    if (_mapController == null || widget.navigationData.fullRoute?.isEmpty != false) return;

    try {
      // 새 폴리라인 생성
      final routePolyline = NPolylineOverlay(
        id: 'navigation_route',
        coords: widget.navigationData.fullRoute!,
        color: Colors.blue,
        width: 8,
      );

      await _mapController!.addOverlay(routePolyline);
    } catch (e) {
      print('🔥 경로 그리기 오류: $e');
    }
  }

  // 마커들 설정
  Future<void> _setupMarkers() async {
    if (_mapController == null) return;

    try {
      // 출발지 마커
      if (widget.navigationData.fullRoute?.isNotEmpty == true) {
        final startMarker = NMarker(
          id: 'start',
          position: widget.navigationData.fullRoute!.first,
          caption: NOverlayCaption(text: '출발'),
          icon: await NOverlayImage.fromWidget(
            widget: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
            size: Size(30, 30),
            context: context,
          ),
        );

        await _mapController!.addOverlay(startMarker);
      }

      // 도착지 마커
      if (widget.navigationData.fullRoute?.isNotEmpty == true) {
        final endMarker = NMarker(
          id: 'end',
          position: widget.navigationData.fullRoute!.last,
          caption: NOverlayCaption(text: '도착'),
          icon: await NOverlayImage.fromWidget(
            widget: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Icon(Icons.flag, color: Colors.white, size: 20),
            ),
            size: Size(30, 30),
            context: context,
          ),
        );

        await _mapController!.addOverlay(endMarker);
      }

      // 현재 위치 마커
      _updateCurrentLocationMarker();
    } catch (e) {
      print('🔥 마커 설정 오류: $e');
    }
  }

  // 현재 위치 마커 업데이트
  void _updateCurrentLocationMarker() async {
    if (_mapController == null || widget.currentLocation == null) return;

    try {
      // 기존 현재 위치 마커 제거
      try {
        await _mapController!.deleteOverlay(NOverlayInfo(type: NOverlayType.marker, id: 'current_location'));
      } catch (e) {
        // 마커가 없으면 무시
      }

      // 현재 위치 마커 생성
      final currentLocationMarker = NMarker(
        id: 'current_location',
        position: widget.currentLocation!,
        icon: await NOverlayImage.fromWidget(
          widget: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          size: Size(20, 20),
          context: context,
        ),
      );

      await _mapController!.addOverlay(currentLocationMarker);
    } catch (e) {
      print('🔥 현재 위치 마커 업데이트 오류: $e');
    }
  }

  // 카메라 위치 업데이트 (현재 위치 추적)
  void _updateCameraPosition() {
    if (_mapController == null || widget.currentLocation == null) return;

    try {
      _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(target: widget.currentLocation!, zoom: 16)
      );
    } catch (e) {
      print('🔥 카메라 위치 업데이트 오류: $e');
    }
  }

  // 경로 전체가 보이도록 카메라 조정
  void _fitCameraToRoute() {
    if (_mapController == null || widget.navigationData.fullRoute?.isEmpty != false) return;

    try {
      List<NLatLng> route = widget.navigationData.fullRoute!;

      double minLat = route.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat = route.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
      double minLng = route.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng = route.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

      NLatLngBounds bounds = NLatLngBounds(
          southWest: NLatLng(minLat, minLng),
          northEast: NLatLng(maxLat, maxLng)
      );

      _mapController!.updateCamera(
          NCameraUpdate.fitBounds(bounds, padding: EdgeInsets.all(50))
      );
    } catch (e) {
      print('🔥 카메라 피팅 오류: $e');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
