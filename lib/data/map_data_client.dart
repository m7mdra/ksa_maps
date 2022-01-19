import 'package:dio/dio.dart';

import 'error_handler.dart';
import 'map_data_repository.dart';
import 'model/query_result.dart';

class MapDataClient implements MapDataRepository {
  final Dio _httpClient;
  CancelToken? _cancelToken;

  MapDataClient(this._httpClient);

  @override
  Future<QueryResultResponse> geoSearch(String query, String lang,
      List<double> bounds, List<double> center) async {
    try {

      var response = await _httpClient.get(
        "geosearch",
        queryParameters: {
          "query": query,
          "page": 1,
          "lang": "en",
          "bounds": bounds.join(),
          "center": center.join(),
          "ser": 1
        },
      );
      if (response.data is Map) {
        return QueryResultResponse.fromJson([]);
      } else {
        return QueryResultResponse.fromJson(response.data);
      }
    } on DioError catch (err) {
      throw handleDioError(err);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<QueryResultResponse> geoSearchNextPage(String query, String lang,
      int page, List<double> bounds, List<double> center) async {
    try {

      var response = await _httpClient.get("geosearch",
          queryParameters: {
            "query": query,
            "page": page,
            "lang": "en",
            "bounds": bounds.join(),
            "center": center.join(),
            "ser": 1
          });
      if (response.data is Map) {
        return QueryResultResponse.fromJson([]);
      } else {
        return QueryResultResponse.fromJson(response.data);
      }
    } on DioError catch (err) {
      throw handleDioError(err);
    } catch (error) {
      rethrow;
    }
  }
}
