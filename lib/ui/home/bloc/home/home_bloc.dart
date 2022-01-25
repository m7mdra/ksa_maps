import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/di/dependency_provider.dart';
import 'package:ksa_maps/ui/home/bloc/home/route.dart';
import 'package:ksa_maps/ui/home/bloc/route/route_bloc.dart';

import 'package:meta/meta.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final RouteBloc _routeBloc;
  CurrentScreen _currentScreen = CurrentScreen.search;
  final _routesPoint = <RoutePoint>[
    RoutePoint(routeType: RouteType.start),
    RoutePoint(routeType: RouteType.end)
  ];

  void _resetRoutePoints() {
    _routesPoint.removeWhere((element) => element.routeType == RouteType.stop);
    for (var element in _routesPoint) {
      element.locationPoint = null;
    }
  }

  HomeBloc(this._routeBloc) : super(HomeInitial()) {
    on<NavigationToSearch>((event, emit) {
      _currentScreen = CurrentScreen.search;
      _resetRoutePoints();
      emit(ClearAllOnMap());
      emit(NavigationSearch());
    });
    on<NavigationToRoute>((event, emit) {
      _currentScreen = CurrentScreen.route;
      _resetRoutePoints();
      emit(ClearAllOnMap());
      emit(NavigationRoute(_routesPoint));
    });
    on<NavigationToFavorite>((event, emit) {
      _currentScreen = CurrentScreen.favorite;
      emit(NavigationFavorite());
    });
    on<NavigationToSettings>((event, emit) {
      _currentScreen = CurrentScreen.settings;
      emit(NavigationSettings());
    });
    on<SearchLocationSelected>((event, emit) {
      emit(ShowSearchResultAndLocationOnMap(event.result));
    });
    on<OnBackPress>((event, emit) {
      if(_currentScreen==CurrentScreen.route){
       add(NavigationToRoute());
      }else {
        add(NavigationToSearch());
      }
    });
    on<OnStartPointSelect>((event, emit) {
      _routesPoint.first.locationPoint = event.result;
      emit(ShowRouteStartPointLocation(event.result));
      emit(NavigationRoute(_routesPoint));

      if (_shouldDoSearchRoute()) {
        _searchForRoutes();
      }
    });
    on<OnEndPointSelect>((event, emit) {
      _routesPoint.last.locationPoint = event.result;
      emit(ShowRouteEndPointLocation(_routesPoint));
      emit(NavigationRoute(_routesPoint));

      if (_shouldDoSearchRoute()) {
        _searchForRoutes();
      }
    });
    on<OnStopPointSelect>((event, emit) {
      var routePointWithId =
          _routesPoint.firstWhere((element) => element.id == event.point.id);
      routePointWithId.locationPoint = event.result;
      emit(ShowRouteEndPointLocation(_routesPoint));
      emit(NavigationRoute(_routesPoint));
      if (_shouldDoSearchRoute()) {
        _searchForRoutes();
      }
    });
    on<OnStopPointRemove>((event, emit) {
      _routesPoint.removeWhere((element) => element.id == event.point.id);
      emit(ShowRouteEndPointLocation(_routesPoint));
      emit(NavigationRoute(_routesPoint));
      if (_shouldDoSearchRoute()) {
        _searchForRoutes();
      }
    });

    on<OnStopPointAdd>((event, emit) {
      _routesPoint.insert(1, RoutePoint(routeType: RouteType.stop));
      emit(NavigationRoute(_routesPoint));
    });
  }

  bool _shouldDoSearchRoute() {
    var routes = List.from(_routesPoint);
    routes.retainWhere((value) => value.locationPoint != null);
    return routes.length > 1;
  }

  @override
  void onTransition(Transition<HomeEvent, HomeState> transition) {
    // TODO: implement onTransition
    super.onTransition(transition);
    print(transition);
  }

  void _searchForRoutes() {
    emit(ShowRouteSearchContent());
    var coordinates = _routesPoint
        .map((e) => e.locationPoint?.coordinates())
        .map((e) => "${e?.longitude},${e?.latitude}")
        .toList();

    _routeBloc.add(SearchForRoutes(coordinates.join(";")));
  }
}

enum CurrentScreen { search, route, favorite, settings }
