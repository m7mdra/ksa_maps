import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ksa_maps/360_button.dart';
import 'package:ksa_maps/map_zoom_controls.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import 'location_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MaplibreMapController? _mapController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var _currentSelection = 0;

  void _onMapReady(MaplibreMapController controller) async {
    _mapController = controller;
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
              onStyleLoadedCallback: () async {
                await _mapController?.setMapLanguage("name_ar");
              },
              minMaxZoomPreference: const MinMaxZoomPreference(4, 19),
              myLocationRenderMode: MyLocationRenderMode.NORMAL,
              zoomGesturesEnabled: true,
              // cameraTargetBounds: CameraTargetBounds(LatLngBounds(
              //     southwest: LatLng(25.193437, 14.298024),
              //     northeast: LatLng(67.380937, 33.625229))),
              onMapClick: (point, coordinates) {
                print(coordinates);
              },
              styleString:
                  "https://ksamaps.com/api/style?key=15b07b3081c5b96eba9ebbe1d31e929deb757ea242d46853fed3fa85bb4fe02a2db2e6f85390316d63f473bf3a2fc2768e62efebac6e30f08cc8c80429cec482",
              compassEnabled: true,
              initialCameraPosition:
                  const CameraPosition(target: LatLng(24.774265, 46.738586)),
              onMapCreated: _onMapReady,
            ),
            if (_currentSelection == 0)
              const Icon(Icons.search)
            else if (_currentSelection == 1)
              const Icon(Icons.alt_route),
            const Align(child: Button360View(), alignment: Alignment(1, 0.75)),
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

  void _onSelectionChanged(page) {
    setState(() {
      _currentSelection = page;
    });
  }
}
