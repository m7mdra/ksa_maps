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
      var queryResultLast = _routesPoint.last.locationPoint;
      var queryResultFirst = _routesPoint.first.locationPoint;
      _routesPoint.first.locationPoint = event.result;
      if (queryResultLast != null && queryResultFirst != null) {
        print("do request");
      } else {
        emit(ShowRouteStartPointLocation(_routesPoint));
      }
    });
    on<OnEndPointSelect>((event, emit) {
      var queryResultLast = _routesPoint.last.locationPoint;
      var queryResultFirst = _routesPoint.first.locationPoint;
      _routesPoint.last.locationPoint = event.result;
      emit(ShowRouteStartPointLocation(_routesPoint));
      if (queryResultLast != null && queryResultFirst != null) {
        print("do request");
      } else {
        emit(ShowRouteEndPointLocation(_routesPoint));
      }
    });
  }
}

enum CurrentScreen { search, route, favorite, settings }
