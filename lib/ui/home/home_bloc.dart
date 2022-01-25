import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/ui/home/route.dart';
import 'package:ksa_maps/ui/search/bloc/geo_search_bloc.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
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

  HomeBloc() : super(HomeInitial()) {
    on<NavigationToSearch>((event, emit) {
      _currentScreen = CurrentScreen.search;
      emit(ClearAllOnMap());
      emit(NavigationSearch());
    });
    on<NavigationToRoute>((event, emit) {
      _currentScreen = CurrentScreen.route;
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
      add(NavigationToSearch());
    });
    on<OnStartPointSelect>((event, emit) {
      _routesPoint.first.locationPoint = event.result;
      emit(ShowRouteStartPointLocation(event.result));
      emit(NavigationRoute(_routesPoint));

      if (_shouldDoSearchRoute()) {
        print("should do request");
      }
    });
    on<OnStopPointRemove>((event, emit) {
      _routesPoint.removeWhere((element) => element.id == event.point.id);
      emit(ShowRouteEndPointLocation(_routesPoint));
      emit(NavigationRoute(_routesPoint));
      if (_shouldDoSearchRoute()) {
        print("should do request");
      }
    });
    on<OnStopPointSelect>((event, emit) {
      var routePointWithId =
          _routesPoint.firstWhere((element) => element.id == event.point.id);
      routePointWithId.locationPoint = event.result;
      emit(ShowRouteEndPointLocation(_routesPoint));
      emit(NavigationRoute(_routesPoint));
      if (_shouldDoSearchRoute()) {
        print("should do request");
      }
    });
    on<OnStopPointAdd>((event, emit) {
      _routesPoint.insert(1, RoutePoint(routeType: RouteType.stop));
      emit(NavigationRoute(_routesPoint));
    });
    on<OnEndPointSelect>((event, emit) {
      _routesPoint.last.locationPoint = event.result;
      emit(ShowRouteEndPointLocation(_routesPoint));
      emit(NavigationRoute(_routesPoint));

      if (_shouldDoSearchRoute()) {
        print("should do request");
      }
    });
  }

  bool _shouldDoSearchRoute() {
    return _routesPoint
            .takeWhile((value) => value.locationPoint != null)
            .length >=
        2;
  }
}

enum CurrentScreen { search, route, favorite, settings }
