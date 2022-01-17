import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/ui/search/search_page.dart';
import 'package:ksa_maps/ui/widget/360_button.dart';
import 'package:ksa_maps/ui/widget/location_button.dart';
import 'package:ksa_maps/ui/widget/map_zoom_controls.dart';
import 'package:ksa_maps/ui/widget/search_widget.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MaplibreMapController? _mapController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var _currentSelection = 0;
  var cameraTilted = false;

  void _onMapReady(MaplibreMapController controller) async {
    _mapController = controller;
    _mapController?.onSymbolTapped.add(onSymbolTapped);
  }

  void onSymbolTapped(Symbol symbol) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              ListTile(
                title: Text(
                    "Direction from:\n${symbol.data?['name'] ?? "Here"}"),
                subtitle: Text(symbol.data?["fullAddress"]),

                onTap: () {},
              ),
              ListTile(
                title: Text(
                    "Direction to:\n${symbol.data?['name'] ?? "Here"}"),
                subtitle: Text(symbol.data?["fullAddress"]),
                onTap: () {},
              ),
            ], mainAxisSize: MainAxisSize.min),
          );
        });
  }

  void _resetAll() {
    _mapController?.clearSymbols();
    _mapController?.clearLines();
  }

  void _locateUser() async {
    final Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
    var latitude = locationData.latitude;
    var longitude = locationData.longitude;

    if (latitude != null && longitude != null) {
      _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 10));
    }
  }

//        maxBounds: [[25.193437, 14.298024], [67.380937, 33.625229]],
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentSelection,
        onTap: _onSelectionChanged,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: "Route"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded), label: "Favorite"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      key: _key,
      body: SafeArea(
        child: Stack(
          children: [
            MaplibreMap(
              attributionButtonMargins: const Point(-1000, -1000),
              // logoViewMargins: const Point(-1000, -1000),
              myLocationTrackingMode: MyLocationTrackingMode.None,
              myLocationEnabled: false,
              annotationOrder: const [
                AnnotationType.symbol,
                AnnotationType.line,
                AnnotationType.circle,
                AnnotationType.fill,
              ],
              onStyleLoadedCallback: () async {
                await _mapController?.addImage(
                    "marker", await loadMarkerImage());

                await _mapController?.setMapLanguage("name_ar");
              },

              minMaxZoomPreference: const MinMaxZoomPreference(4.5, 19),
              myLocationRenderMode: MyLocationRenderMode.NORMAL,
              zoomGesturesEnabled: true,

              // cameraTargetBounds: CameraTargetBounds(LatLngBounds(
              //     southwest: LatLng(25.193437, 14.298024),
              //     northeast: LatLng(67.380937, 33.625229))),
              onMapClick: (point, coordinates) async {},
              styleString:
                  "https://ksamaps.com/api/style?key=15b07b3081c5b96eba9ebbe1d31e929deb757ea242d46853fed3fa85bb4fe02a2db2e6f85390316d63f473bf3a2fc2768e62efebac6e30f08cc8c80429cec482",
              compassEnabled: true,
              initialCameraPosition:
                  const CameraPosition(target: LatLng(24.774265, 46.738586),zoom: 5),
              onMapCreated: _onMapReady,
            ),
            if (_currentSelection == 0)
              ClickableSearchWidget(onTap: () async {
                var bounds = await _mapController?.getVisibleRegion();

                if (bounds != null) {
                  LatLng center = LatLng(
                    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                    (bounds.northeast.longitude + bounds.southwest.longitude) /
                        2,
                  );
                  var result = await Navigator.push<QueryResult>(context,
                      MaterialPageRoute(builder: (context) {
                    return SearchPage(
                      center: [center.latitude, center.longitude],
                      bounds: [
                        bounds.northeast.latitude,
                        bounds.northeast.longitude,
                        bounds.southwest.latitude,
                        bounds.southwest.longitude
                      ],
                    );
                  }));
                  if (result != null) {
                    Future.wait([]);
                    await _mapController?.addImage(
                        "marker", await loadMarkerImage());
                    await _mapController?.addSymbol(
                        SymbolOptions(
                            geometry: result.coordinates(),
                            iconImage: "marker"),
                        result.toJson());
                    await _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                            target: result.coordinates(), zoom: 15)));
                  }
                }
              })
            else if (_currentSelection == 1)
              const Icon(Icons.alt_route),
            Align(
                child: Button360View(
                  onTap: () {
                    var newCameraTilt = 0.0;
                    if (cameraTilted) {
                      newCameraTilt = 0.0;
                    } else {
                      newCameraTilt = 60.0;
                    }
                    setState(() {
                      cameraTilted = !cameraTilted;
                    });
                    _mapController
                        ?.animateCamera(CameraUpdate.tiltTo(newCameraTilt));
                  },
                ),
                alignment: const Alignment(1, 0.75)),
            Align(
                child: LocationButton(
                  onTap: _locateUser,
                ),
                alignment: const Alignment(1, 1)),
            Align(
              alignment: const Alignment(1, 0.45),
              child: MapZoomControls(zoomInCallback: () {
                _mapController?.animateCamera(CameraUpdate.zoomIn());
              }, zoomOutCallback: () {
                _mapController?.animateCamera(CameraUpdate.zoomOut());
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load("assets/image/marker.png");
    return byteData.buffer.asUint8List();
  }

  void _onSelectionChanged(page) {
    setState(() {
      _currentSelection = page;
    });
  }
}
