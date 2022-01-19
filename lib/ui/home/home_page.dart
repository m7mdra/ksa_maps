import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/data/ksamaps_resources.dart';
import 'package:ksa_maps/ui/search/search_page.dart';
import 'package:ksa_maps/ui/widget/360_button.dart';
import 'package:ksa_maps/ui/widget/layers_button.dart';
import 'package:ksa_maps/ui/widget/location_button.dart';
import 'package:ksa_maps/ui/widget/map_style_features.dart';
import 'package:ksa_maps/ui/widget/map_zoom_controls.dart';
import 'package:ksa_maps/ui/widget/search_widget.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

const kPoiLayers = ['pois1', 'pois2', 'pois3', 'pois4', 'pois5'];

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
  var _satelliteAdded = false;
  var _trafficAdded = false;
  QueryResult? _searchResult;

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
                title:
                    Text("Direction from:\n${symbol.data?['name'] ?? "Here"}"),
                subtitle: Text(symbol.data?["fullAddress"]),
                onTap: () {},
              ),
              ListTile(
                title: Text("Direction to:\n${symbol.data?['name'] ?? "Here"}"),
                subtitle: Text(symbol.data?["fullAddress"]),
                onTap: () {},
              ),
            ], mainAxisSize: MainAxisSize.min),
          );
        });
  }

  void _resetAll() async {
    setState(() {
      _searchResult = null;
    });
    await _mapController?.clearSymbols();
    await _mapController?.clearLines();
    await _mapController?.clearCircles();
    await _mapController?.clearFills();
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
                await _mapController?.addSource(
                  "satellite",
                  const RasterSourceProperties(
                      tiles: [KsaMapsResources.kRasterSatelliteTileUrl],
                      tileSize: 256,
                      attribution:
                          KsaMapsResources.kRasterSatelliteTileAttribution),
                );
                await _mapController?.addSource(
                    "traffic",
                    const VectorSourceProperties(
                      tiles: [KsaMapsResources.kVectorTrafficTileUrl],
                      minzoom: 9,
                      maxzoom: 19,
                      attribution:
                          KsaMapsResources.kVectorTrafficTileAttribution,
                    ));
              },

              minMaxZoomPreference: const MinMaxZoomPreference(4.5, 19),
              myLocationRenderMode: MyLocationRenderMode.NORMAL,
              zoomGesturesEnabled: true,

              // cameraTargetBounds: CameraTargetBounds(LatLngBounds(
              //     southwest: LatLng(25.193437, 14.298024),
              //     northeast: LatLng(67.380937, 33.625229))),
              onMapClick: (point, coordinates) async {
/*
                try {
                  var features = await _mapController?.queryRenderedFeatures(
                      Point(point.x - 10 / 2, point.y - 20 / 2),
                      kPoiLayers, []);
                  if (features == null || features.isEmpty) return;

                  print(features);
                } catch (error) {
                  print(error);
                }
*/
              },
              styleString: KsaMapsResources.kStyleTilesUrl,
              compassEnabled: true,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(24.774265, 46.738586), zoom: 5),
              onMapCreated: _onMapReady,
            ),
            if (_currentSelection == 0)
              ClickableSearchWidget(
                  text: _searchResult?.name ,
                  subText: _searchResult?.fullAddress,
                  onTap: () async {
                    var bounds = await _mapController?.getVisibleRegion();

                    if (bounds != null) {
                      LatLng center = LatLng(
                        (bounds.northeast.latitude +
                                bounds.southwest.latitude) /
                            2,
                        (bounds.northeast.longitude +
                                bounds.southwest.longitude) /
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
                        await _mapController?.addImage(
                            "marker", await loadMarkerImage());
                        await _mapController?.addSymbol(
                            SymbolOptions(
                                geometry: result.coordinates(),
                                iconSize: 3.5,
                                iconImage: "marker"),
                            result.toJson());
                        await _mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                                target: result.coordinates(), zoom: 15)));
                        setState(() {
                          _searchResult = result;
                        });
                      }
                    }
                  })
            else if (_currentSelection == 1)
              const Icon(Icons.alt_route),
            Align(
                child: LayersButton(onTap: () async {
                  _showFeatureAndLayerBottomSheet();
                }),
                alignment: const Alignment(1, -0.5)),
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
    _resetAll();
    setState(() {
      _currentSelection = page;
    });
  }

  void _showFeatureAndLayerBottomSheet() {
    showModalBottomSheet(
        context: _key.currentContext!,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return MapStyleFeatures(
                satelliteAdded: _satelliteAdded,
                isTrafficEnabled: _trafficAdded,
                onNormalSelected: () async {
                  await _mapController?.removeLayer("satellite");
                  setState(() {
                    _satelliteAdded = false;
                  });
                },
                onSatelliteSelected: () async {
                  await _mapController?.addLayer(
                      "satellite", "satellite", const RasterLayerProperties(),
                      belowLayerId: "land");
                  setState(() {
                    _satelliteAdded = true;
                  });
                },
                onTrafficToggle: () async {
                  if (_trafficAdded) {
                    print("removing traffic ");

                    _mapController?.removeLayer("traffic").then((_) {
                      print("remove traffic layer");
                      setState(() {
                        _trafficAdded = false;
                      });
                    }).catchError((error) {
                      print("remove traffic layer error");
                    });
                  } else {
                    print("adding traffic ");
                    _mapController
                        ?.addLayer(
                            "traffic",
                            "traffic",
                            const LineLayerProperties(
                              lineColor: [
                                "interpolate",
                                ["linear"],
                                [
                                  "number",
                                  ["get", "traffic_level"]
                                ],
                                0,
                                "gray",
                                0.1,
                                "orangered",
                                0.3,
                                "tomato",
                                0.5,
                                "goldenrod",
                                0.7,
                                "yellow",
                                1,
                                "limegreen"
                              ],
                              lineWidth: 2,
                              lineCap: "round",
                              lineJoin: "round",
                            ),
                            sourceLayer: "Traffic flow",
                            belowLayerId: "stnw4_label")
                        .then((_) {
                      print("add traffic layer");
                      setState(() {
                        _trafficAdded = true;
                      });
                    }).catchError((error) {
                      print("add traffic layer error");
                    });
                  }
                },
              );
            },
          );
        });
  }
}

