import 'dart:async' show Future;

import 'model/query_result.dart';

abstract class MapDataRepository {
  Future<QueryResultResponse> geoSearch(
      String query, String lang, List<double> bounds, List<double> center);

  Future<QueryResultResponse> geoSearchNextPage(String query, String lang,
      int page, List<double> bounds, List<double> center);
}
