import 'dart:async' show Future;

import 'package:ksa_maps/data/model/route_response.dart';

import 'model/query_result.dart';

abstract class MapDataRepository {
  Future<QueryResultResponse> geoSearch(
      String query, String lang, List<double> bounds, List<double> center);

  Future<QueryResultResponse> geoSearchNextPage(String query, String lang,
      int page, List<double> bounds, List<double> center);

  Future<RouteResponse> findRoute(String coordinates);
}
