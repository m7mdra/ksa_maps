import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/data/ksamaps_resources.dart';
import 'package:ksa_maps/data/model/map_features.dart';
import 'package:ksa_maps/di/dependency_provider.dart';
import 'package:ksa_maps/polyline.dart';
import 'package:ksa_maps/ui/home/bloc/home/home_bloc.dart';
import 'package:ksa_maps/ui/home/bloc/route/route_bloc.dart';
import 'package:ksa_maps/ui/search/search_page.dart';
import 'package:ksa_maps/ui/settings/settings_page.dart';
import 'package:ksa_maps/ui/widget/360_button.dart';
import 'package:ksa_maps/ui/widget/layers_button.dart';
import 'package:ksa_maps/ui/widget/location_button.dart';
import 'package:ksa_maps/ui/widget/map_style_features.dart';
import 'package:ksa_maps/ui/widget/map_zoom_controls.dart';
import 'package:ksa_maps/ui/widget/route_planning_widget.dart';
import 'package:ksa_maps/ui/widget/route_view_widget.dart';
import 'package:ksa_maps/ui/widget/search_widget.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import 'bloc/home/route.dart';

var poiLayers = ['pois1', 'pois2', 'pois3', 'pois4', 'pois5'];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _homeBloc;
  late RouteBloc _routeBloc;
  Line? _selectedLineRoute;

  MaplibreMapController? _mapController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var _currentSelection = 0;
  var cameraTilted = false;
  var _satelliteAdded = false;
  var _trafficAdded = false;

  void _onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;
    _mapController?.onSymbolTapped.add(onSymbolTapped);
  }

  @override
  void initState() {
    super.initState();
    _routeBloc = RouteBloc(D.provide());

    _homeBloc = HomeBloc(_routeBloc);
    _homeBloc.add(NavigationToSearch());
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
                onTap: () {
                  setState(() {});
                },
              ),
              ListTile(
                title: Text("Direction to:\n${symbol.data?['name'] ?? "Here"}"),
                subtitle: Text(symbol.data?["fullAddress"]),
                onTap: () {
                  _currentSelection = 1;
                  Navigator.pop(context);
                },
              ),
            ], mainAxisSize: MainAxisSize.min),
          );
        });
  }

  void _resetAll() async {
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

  _homeBlocListener(context, HomeState state) async {
    if (state is ShowSearchResultAndLocationOnMap) {
      animateCameraToResultLocation(state.result);
    }
    if (state is ShowRouteStartPointLocation) {
      var coordinates = state.result.coordinates();
      await _mapController?.addSymbol(SymbolOptions(
          geometry: coordinates, iconImage: "start_point", iconSize: 3.5));
      await _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(coordinates, 13));
    }

    if (state is ShowRouteEndPointLocation) {
      _showMapBoundsForRoute(state.routes);
    }
    if (state is ClearAllOnMap) {
      _resetAll();
    }
  }

  void _showMapBoundsForRoute(List<RoutePoint> routes) async {
    var list = List<RoutePoint>.from(routes);

    list.sort((first, second) {
      return first.compareTo(second);
    });
    list.removeWhere((element) => element.locationPoint == null);
    if (list.isEmpty) {
      return;
    }
    var first = list.first;
    var last = list.last;
    var firstLocation = last.locationPoint;
    var lastLocation = first.locationPoint;
    if (lastLocation != null && firstLocation != null) {
      await _mapController?.clearSymbols();
      var padding = 100.0;

      for (var element in list) {
        var pointImageName = "";
        switch (element.routeType) {
          case RouteType.start:
            pointImageName = "start_point";
            break;
          case RouteType.end:
            pointImageName = "end_point";

            break;
          case RouteType.stop:
            pointImageName = "stop_point";
            break;
        }
        await _mapController?.addSymbol(SymbolOptions(
            geometry: element.locationPoint?.coordinates(),
            iconImage: pointImageName,
            iconSize: 3.5));
      }

      await _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: lastLocation.coordinates(),
              northeast: firstLocation.coordinates()),
          top: padding,
          bottom: padding,
          right: padding,
          left: padding));
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
      body: BlocListener(
        bloc: _routeBloc,
        listener: _routeBlocListener,
        child: BlocListener(
          listener: _homeBlocListener,
          bloc: _homeBloc,
          child: SafeArea(
            child: Stack(
              children: [
                MaplibreMap(
                    attributionButtonMargins: const math.Point(-1000, -1000),
                    // logoViewMargins: const Point(-1000, -1000),
                    myLocationTrackingMode: MyLocationTrackingMode.None,
                    myLocationEnabled: false,
                    annotationOrder: const [
                      AnnotationType.symbol,
                      AnnotationType.line,
                      AnnotationType.circle,
                      AnnotationType.fill,
                    ],
                    onMapClick: _onMapClick,
                    onStyleLoadedCallback: _onStyleLoaded,
                    minMaxZoomPreference: const MinMaxZoomPreference(4.5, 19),
                    myLocationRenderMode: MyLocationRenderMode.NORMAL,
                    zoomGesturesEnabled: true,
                    styleString: KsaMapsResources.kMobileStyleTilesUrl,
                    compassEnabled: true,
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(24.774265, 46.738586), zoom: 12),
                    onMapCreated: _onMapCreated),
                Align(
                    child: LayersButton(onTap: _showFeatureAndLayerBottomSheet),
                    alignment: const Alignment(1, -0.0)),
                Align(
                    child: Button360View(onTap: _onChangeTiltedTap),
                    alignment: const Alignment(1, 0.75)),
                Align(
                    child: LocationButton(onTap: _locateUser),
                    alignment: const Alignment(1, 1)),
                Align(
                    alignment: const Alignment(1, 0.45),
                    child: MapZoomControls(
                        zoomInCallback: zoomInCallback,
                        zoomOutCallback: zoomOutCallback)),
                BlocBuilder(
                  buildWhen: _buildCondition,
                  builder: (context, state) {
                    if (state is NavigationSearch) {
                      return ClickableSearchWidget(
                          text: null, onTap: _onSearchBarTap);
                    }
                    if (state is NavigationRoute) {
                      return RoutePlanningWidget(
                        routesPoint: state.initRoutes,
                        onAddStartPointTap: _onAddStartPointTap,
                        onAddStopPointTap: _onAddStopPointTap,
                        onAddNewStopPointTap: _onAddNewStopPointTap,
                        onDeleteStopPointTap: _onDeleteStopPointTap,
                        onAddEndPointTap: _onAddEndPointTap,
                        onSearchClick: _onSearchRouteClick,
                        onClearClick: _onClearPointsClick,
                      );
                    }
                    if (state is NavigationFavorite) {
                      return Container(color: Colors.red);
                    }
                    if (state is NavigationSettings) {
                      return const SettingsPage();
                    }
                    if (state is ShowSearchResultAndLocationOnMap) {
                      return ClickableSearchWidget(
                        text: state.result.name ?? "",
                        onTap: _onSearchBarTap,
                        prefixIcon: GestureDetector(
                          onTap: () {
                            _homeBloc.add(OnBackPress());
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
                      );
                    }
                    if (state is ShowRouteSearchContent) {
                      return BlocProvider.value(
                          value: _routeBloc,
                          child: RoutesViewWidget(
                            onBackTap: () {
                              _homeBloc.add(OnBackPress());
                            },
                            itemClickCallback: (route) async {
                              if (_selectedLineRoute != null) {
                                _removeSelectedLine();
                              }
                              var result = PolylineCodec.decode(route.geometry);
                              var mapResult = result
                                  .map((e) => LatLng(
                                      e.first.toDouble(), e.last.toDouble()))
                                  .toList();

                              _selectedLineRoute =
                                  await _mapController?.addLine(LineOptions(
                                      geometry: mapResult,
                                      lineWidth: 5,
                                      lineJoin: "round",
                                      lineColor: Colors.blue.toHexStringRGB()));
                            },
                          ));
                    }
                    return Container();
                  },
                  bloc: _homeBloc,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var point;

  void _onMapClick(point, coordinate) async {
    setState(() {
      this.point = point;
    });
    var rect = rectFromPoint(point);

    print(rect);
    var features =
        await _mapController?.queryRenderedFeatures(point, poiLayers, []);
    if (features != null) {
      features
          .map((e) => MapFeature.fromJson(e))
          .where((element) => element.geometry.type.toLowerCase() == "point")
          .toList()
          .forEach((element) {
        log(element.toString());
      });
    }
  }

  void _onClearPointsClick() {
    _homeBloc.add(ClearSelectedPoints());
  }

  void _onSearchRouteClick() {
    _homeBloc.add(SubmitRouteSearch());
  }

  void _routeBlocListener(BuildContext context, RouteState state) async {
    if (state is RouteSuccess) {
      state.response.routes.map((e) => e.geometry).forEach((element) async {
        var decode = PolylineCodec.decode(element);
        var latLngList = decode
            .map((e) => LatLng(e.first.toDouble(), e.last.toDouble()))
            .toList();
        var list = List.of(latLngList);
        list.sort((first, second) {
          return first.latitude.compareTo(second.latitude);
        });
        await _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: list.first, northeast: list.last),
            top: 200,
            bottom: 200,
            left: 200,
            right: 200));
        await _mapController?.addLine(LineOptions(
            geometry: latLngList,
            lineColor: Colors.blueGrey.toHexStringRGB(),
            lineWidth: 4,
            lineJoin: "round",
            lineOpacity: 0.5));
      });
    }
  }

  void _onAddEndPointTap() async {
    var result = await _getQueryResult();

    if (result != null) {
      _homeBloc.add(OnEndPointSelect(result));
    }
  }

  _onDeleteStopPointTap(point) {
    _homeBloc.add(OnStopPointRemove(point));
  }

  void _onAddNewStopPointTap() {
    _homeBloc.add(OnStopPointAdd());
  }

  _onAddStopPointTap(point) async {
    var result = await _getQueryResult();
    if (result != null) {
      _homeBloc.add(OnStopPointSelect(result, point));
    }
  }

  void _onAddStartPointTap() async {
    var result = await _getQueryResult();

    if (result != null) {
      _homeBloc.add(OnStartPointSelect(result));
    }
  }

  bool _buildCondition(previousState, currentState) {
    return currentState is NavigationSearch ||
        currentState is NavigationRoute ||
        currentState is NavigationFavorite ||
        currentState is NavigationSettings ||
        currentState is ShowSearchResultAndLocationOnMap ||
        currentState is ShowRouteSearchContent;
  }

  void zoomOutCallback() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void zoomInCallback() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _onStyleLoaded() async {
    await _mapController?.addImage(
        "marker", await loadMarkerImage("assets/image/marker.png"));
    await _mapController?.addImage(
        "start_point", await loadMarkerImage("assets/image/start_point.png"));
    await _mapController?.addImage(
        "end_point", await loadMarkerImage("assets/image/end_point.png"));
    await _mapController?.addImage(
        "stop_point", await loadMarkerImage("assets/image/stop_point.png"));
    await _mapController?.setMapLanguage("name_ar");
    await _mapController?.addSource(
      "satellite",
      const RasterSourceProperties(
          tiles: [KsaMapsResources.kRasterSatelliteTileUrl],
          tileSize: 256,
          attribution: KsaMapsResources.kRasterSatelliteTileAttribution),
    );
    await _mapController?.addSource(
        "traffic",
        const VectorSourceProperties(
          tiles: [KsaMapsResources.kVectorTrafficTileUrl],
          minzoom: 9,
          maxzoom: 19,
          attribution: KsaMapsResources.kVectorTrafficTileAttribution,
        ));
  }

  void _onChangeTiltedTap() {
    var newCameraTilt = 0.0;
    if (cameraTilted) {
      newCameraTilt = 0.0;
    } else {
      newCameraTilt = 60.0;
    }
    setState(() {
      cameraTilted = !cameraTilted;
    });
    _mapController?.animateCamera(CameraUpdate.tiltTo(newCameraTilt));
  }

  Future<Uint8List> loadMarkerImage(String name) async {
    var byteData = await rootBundle.load(name);
    return byteData.buffer.asUint8List();
  }

  void _onSelectionChanged(page) {
    if (page == 0) {
      _homeBloc.add(NavigationToSearch());
    } else if (page == 1) {
      _homeBloc.add(NavigationToRoute());
    } else if (page == 2) {
      _homeBloc.add(NavigationToFavorite());
    } else {
      _homeBloc.add(NavigationToSettings());
    }
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
                  await _removeSatellite(setState);
                },
                onSatelliteSelected: () async {
                  await _addSatellite(setState);
                },
                onTrafficToggle: () async {
                  if (_trafficAdded) {
                    _removeTraffic(setState);
                  } else {
                    _addTraffic(setState);
                  }
                },
              );
            },
          );
        });
  }

  Future<void> _removeSatellite(StateSetter setState) async {
    await _mapController?.removeLayer("satellite");
    setState(() {
      _satelliteAdded = false;
    });
  }

  Future<void> _addSatellite(StateSetter setState) async {
    await _mapController?.addLayer(
        "satellite", "satellite", const RasterLayerProperties(),
        belowLayerId: "land");
    setState(() {
      _satelliteAdded = true;
    });
  }

  void _addTraffic(StateSetter setState) {
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
      setState(() {
        _trafficAdded = true;
      });
    });
  }

  void _removeTraffic(StateSetter setState) {
    _mapController?.removeLayer("traffic").then((_) {
      setState(() {
        _trafficAdded = false;
      });
    });
  }

  Future<QueryResult?> _getQueryResult() async {
    var bounds = await _mapController?.getVisibleRegion();

    if (bounds != null) {
      LatLng center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      var result = await Navigator.push<QueryResult>(context,
          MaterialPageRoute(builder: (context) {
        return SearchPage(
          center: [center.longitude, center.latitude],
          bounds: [
            bounds.northeast.longitude,
            bounds.northeast.latitude,
            bounds.southwest.longitude,
            bounds.southwest.latitude
          ],
        );
      }));
      return result;
    }
  }

  void _onSearchBarTap() async {
    var result = await _getQueryResult();
    if (result != null) {
      _homeBloc.add(SearchLocationSelected(result));
    }
  }

  Future<void> animateCameraToResultLocation(QueryResult result) async {
    await _mapController?.addSymbol(
        SymbolOptions(
            geometry: result.coordinates(), iconSize: 3.5, iconImage: "marker"),
        result.toJson());
    await _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: result.coordinates(), zoom: 15)));
  }

  void _removeSelectedLine() {
    _mapController?.removeLine(_selectedLineRoute!);
  }
}

class RectPainter extends CustomPainter {
  final math.Point point;

  RectPainter(this.point);

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = rectFromPoint(point);

    var paint = Paint();
    paint.color = Colors.red;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant RectPainter oldDelegate) {
    return oldDelegate.point != point;
  }
}

Rect rectFromPoint(math.Point point) {
  var modifier = 20;
  var offset =
      Offset(point.x.toDouble() - modifier, point.y.toDouble() - modifier);
  var offset1 =
      Offset(point.x.toDouble() + modifier, point.y.toDouble() + modifier);
  var rect = Rect.fromPoints(offset, offset1);
  print(rect);
  return rect;
}
