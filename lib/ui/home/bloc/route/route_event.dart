part of 'route_bloc.dart';

@immutable
abstract class RouteEvent {}
class SearchForRoutes extends RouteEvent{
  final String coordinates;

  SearchForRoutes(this.coordinates);
}
