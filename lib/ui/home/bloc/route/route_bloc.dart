import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ksa_maps/data/map_data_repository.dart';
import 'package:ksa_maps/data/model/route_response.dart';
import 'package:meta/meta.dart';

part 'route_event.dart';

part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final MapDataRepository _repository;

  RouteBloc(this._repository) : super(RouteInitial()) {
    on<SearchForRoutes>((event, emit) async {
      try {
        emit(RouteLoading());
        var response = await _repository.findRoute(event.coordinates);
        if (response.code.toLowerCase() == "ok") {
          emit(RouteSuccess(response));
        } else {
          emit(RouteFailed());
        }
      } catch (error) {
        emit(RouteFailed());
      }
    });
  }
}
