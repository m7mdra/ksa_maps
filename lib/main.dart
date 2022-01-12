import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

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
  final Completer<MaplibreMapController> _mapCompleter = Completer();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var _currentSelection = 0;

  void _onMapReady(MaplibreMapController controller) async {
    _mapCompleter.complete(controller);
  }

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
          BottomNavigationBarItem(icon: Icon(Icons.list_rounded), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
      key: _key,
      body: SafeArea(
        child: Stack(
          children: [
            MaplibreMap(
              myLocationTrackingMode: MyLocationTrackingMode.None,
              myLocationEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(3, 15),
              myLocationRenderMode: MyLocationRenderMode.NORMAL,
              zoomGesturesEnabled: true,
              styleString:
                  "https://api.maptiler.com/maps/streets/style.json?key=M5g5zZAp9tzdwq36fzcm",
              compassEnabled: true,
              initialCameraPosition:
                  const CameraPosition(target: LatLng(24.774265, 46.738586)),
              onMapCreated: _onMapReady,
            ),
            if (_currentSelection == 0)
              Icon(Icons.search)
            else if (_currentSelection == 1)
              Icon(Icons.alt_route)
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
