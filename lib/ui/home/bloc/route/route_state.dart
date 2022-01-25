part of 'route_bloc.dart';

@immutable
abstract class RouteState {}

class RouteInitial extends RouteState {}

class RouteLoading extends RouteState {}

class RouteFailed extends RouteState {}

class RouteSuccess extends RouteState {
  final RouteResponse response;

  RouteSuccess(this.response);
}
