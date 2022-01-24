part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class NavigationSearch extends HomeState {}

class NavigationRoute extends HomeState {
  final List<RoutePoint> initRoutes;

  NavigationRoute(this.initRoutes);
}

class NavigationSettings extends HomeState {}

class NavigationFavorite extends HomeState {}

class ShowSearchResultAndLocationOnMap extends HomeState {
  final QueryResult result;

  ShowSearchResultAndLocationOnMap(this.result);
}

class ShowRouteStartPointLocation extends HomeState {
  final List<RoutePoint> route;

  ShowRouteStartPointLocation(this.route);
}

class ShowRouteEndPointLocation extends HomeState {
  final List<RoutePoint> route;

  ShowRouteEndPointLocation(this.route);
}

class ClearAllOnMap extends HomeState {}
