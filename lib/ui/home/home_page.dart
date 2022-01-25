import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/data/ksamaps_resources.dart';
import 'package:ksa_maps/di/dependency_provider.dart';
import 'package:ksa_maps/ui/home/home_bloc.dart';
import 'package:ksa_maps/ui/home/route.dart';
import 'package:ksa_maps/ui/search/search_page.dart';
import 'package:ksa_maps/ui/widget/360_button.dart';
import 'package:ksa_maps/ui/widget/layers_button.dart';
import 'package:ksa_maps/ui/widget/location_button.dart';
import 'package:ksa_maps/ui/widget/map_style_features.dart';
import 'package:ksa_maps/ui/widget/map_zoom_controls.dart';
import 'package:ksa_maps/ui/widget/route_type.dart';
import 'package:ksa_maps/ui/widget/search_widget.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:ksa_maps/data/model/extension_on_query_result.dart';

const kPoiLayers = ['pois1', 'pois2', 'pois3', 'pois4', 'pois5'];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _homeBloc;
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
    _homeBloc = HomeBloc();
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

  _blocListener(context, HomeState state) async {
    if (state is ShowSearchResultAndLocationOnMap) {
      animateCameraToResultLocation(state.result);
    }
    if (state is ShowRouteStartPointLocation) {
      var coordinates = state.result.coordinates();
      await _mapController?.addSymbol(SymbolOptions(
          geometry: coordinates, iconImage: "marker", iconSize: 3.5));
      await _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(coordinates, 12));
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

    var first = list.first;
    var last = list.last;
    var firstLocation = last.locationPoint;
    var lastLocation = first.locationPoint;
    if (lastLocation != null && firstLocation != null) {
      var padding = 100.0;
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
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
        listener: _blocListener,
        bloc: _homeBloc,
        child: SafeArea(
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
                  onStyleLoadedCallback: _onStyleLoaded,
                  minMaxZoomPreference: const MinMaxZoomPreference(4.5, 19),
                  myLocationRenderMode: MyLocationRenderMode.NORMAL,
                  zoomGesturesEnabled: true,
                  styleString: KsaMapsResources.kStyleTilesUrl,
                  compassEnabled: true,
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(24.774265, 46.738586), zoom: 5),
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
                    return RouteSelectionWidget(
                      routesPoint: state.initRoutes,
                      onAddStartPointTap: () async {
                        var result = await _getQueryResult();
                        if (result != null) {
                          _homeBloc.add(OnStartPointSelect(result));
                        }
                      },
                      onAddStopPointTap: (point) async {
                        var result = await _getQueryResult();
                        if (result != null) {
                          _homeBloc.add(OnStopPointSelect(result, point));
                        }
                      },
                      onAddNewStopPointTap: () {
                        _homeBloc.add(OnStopPointAdd());
                      },
                      onDeleteStopPointTap: (point) {
                        _homeBloc.add(OnStopPointRemove(point));
                      },
                      onAddEndPointTap: () async {
                        var result = await _getQueryResult();
                        if (result != null) {
                          _homeBloc.add(OnEndPointSelect(result));
                        }
                      },
                    );
                  }
                  if (state is NavigationFavorite) {
                    return Container(color: Colors.red);
                  }
                  if (state is NavigationSettings) {
                    return Container(color: Colors.blue);
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
                  return Container();
                },
                bloc: _homeBloc,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _buildCondition(previousState, currentState) {
    return currentState is NavigationSearch ||
        currentState is NavigationRoute ||
        currentState is NavigationFavorite ||
        currentState is NavigationSettings ||
        currentState is ShowSearchResultAndLocationOnMap;
  }

  /*void selectRoute(routesPoint, QueryResult result) {
    {
                                         setState(() {
                                           routesPoint.locationPoint = result;
                                         });

                                         var queryResultLast =
                                             _routesPoint.last.locationPoint;
                                         var queryResultFirst =
                                             _routesPoint.first.locationPoint;
                                         if (queryResultLast != null &&
                                             queryResultFirst != null) {
                                           LatLngBounds latLngBounds;
                                           if (queryResultLast.lat! <=
                                               queryResultFirst.lat!) {
                                             latLngBounds = LatLngBounds(
                                                 southwest:
                                                     queryResultLast.coordinates(),
                                                 northeast: queryResultFirst
                                                     .coordinates());
                                           } else {
                                             latLngBounds = LatLngBounds(
                                                 northeast:
                                                     queryResultLast.coordinates(),
                                                 southwest: queryResultFirst
                                                     .coordinates());
                                           }
                                           _mapController?.animateCamera(
                                               CameraUpdate.newLatLngBounds(
                                                   latLngBounds,
                                                   bottom: 100,
                                                   top: 100,
                                                   right: 100,
                                                   left: 100));
                                           var coordinates = _routesPoint
                                               .map((e) =>
                                                   e.locationPoint?.coordinates())
                                               .map((e) =>
                                                   "${e?.longitude},${e?.latitude}")
                                               .toList();
                                         } else {
                                           print("should not search");
                                         }
                                       }
  }
*/
  void zoomOutCallback() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void zoomInCallback() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _onStyleLoaded() async {
    await _mapController?.addImage("marker", await loadMarkerImage());

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

  Future<Uint8List> loadMarkerImage() async {
    var byteData = await rootBundle.load("assets/image/marker.png");
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
                    _mapController?.removeLayer("traffic").then((_) {
                      setState(() {
                        _trafficAdded = false;
                      });
                    }).catchError((error) {});
                  } else {
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
                    }).catchError((error) {});
                  }
                },
              );
            },
          );
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
          center: [center.latitude, center.longitude],
          bounds: [
            bounds.northeast.latitude,
            bounds.northeast.longitude,
            bounds.southwest.latitude,
            bounds.southwest.longitude
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
    await _mapController?.addImage("marker", await loadMarkerImage());
    await _mapController?.addSymbol(
        SymbolOptions(
            geometry: result.coordinates(), iconSize: 3.5, iconImage: "marker"),
        result.toJson());
    await _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: result.coordinates(), zoom: 15)));
  }
}

class RouteSelectionWidget extends StatelessWidget {
  final List<RoutePoint> routesPoint;
  final VoidCallback? onAddStartPointTap;
  final VoidCallback? onAddEndPointTap;
  final Function(RoutePoint)? onAddStopPointTap;
  final VoidCallback? onAddNewStopPointTap;
  final Function(RoutePoint)? onDeleteStopPointTap;

  const RouteSelectionWidget(
      {Key? key,
      required this.routesPoint,
      this.onAddEndPointTap,
      this.onAddNewStopPointTap,
      this.onDeleteStopPointTap,
      this.onAddStartPointTap,
      this.onAddStopPointTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var point = routesPoint[index];
                return GestureDetector(
                  onTap: () async {
                    switch (point.routeType) {
                      case RouteType.start:
                        onAddStartPointTap?.call();
                        break;
                      case RouteType.end:
                        onAddEndPointTap?.call();

                        break;
                      case RouteType.stop:
                        onAddStopPointTap?.call(point);
                        break;
                    }
                  },
                  child: Row(
                    children: [
                      RouteTypeWidget(routeType: point.routeType),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            point.locationPoint?.name ?? "",
                            maxLines: 1,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      Visibility(
                        child: IconButton(
                            onPressed: () {
                              onDeleteStopPointTap?.call(point);
                            },
                            icon: const Icon(Icons.delete_forever)),
                        visible: point.routeType == RouteType.stop,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        maintainInteractivity: false,
                      )
                    ],
                  ),
                );
              },
              itemCount: routesPoint.length),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(children: [
            TextButton.icon(
                onPressed: onAddNewStopPointTap,
                label: const Text("Add new stop"),
                icon: const Icon(Icons.add_circle_rounded)),
            const Spacer(),
            Text(
                "${routesPoint.where((value) => value.routeType != RouteType.start).length} Stops")
          ]),
        )
      ]),
    );
  }
}
