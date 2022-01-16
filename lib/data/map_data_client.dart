import 'package:dio/dio.dart';
import 'package:ksa_maps/data/model/query_result.dart';

class MapDataClient {
  final Dio _httpClient;

  MapDataClient(this._httpClient);

  //https://ksamaps.com/api/geosearch?query=searc&lang=en&ser=1&page=1&bounds=38.154450,22.529667,66.279450,27.686959&center=52.216950,25.135531

  Future<QueryResultResponse> geoSearch(String query, String lang, int page,
      List<double> bounds, List<double> center) async {
    var response = await _httpClient.get("geosearch", queryParameters: {
      "query": query,
      "page": page,
      "lang": "en",
      "bounds": bounds.join(),
      "center": center.join(),
      "ser": 1,
      "key":
          "15b07b3081c5b96eba9ebbe1d31e929deb757ea242d46853fed3fa85bb4fe02a2db2e6f85390316d63f473bf3a2fc2768e62efebac6e30f08cc8c80429cec482"
    });
    print(response.data);
    return QueryResultResponse.fromJson(response.data);
  }
}

void main() {
  MapDataClient(Dio(BaseOptions(baseUrl: "https://ksamaps.com/api/")))
      .geoSearch(
          "search",
          "ar",
          1,
          [38.154450, 22.529667, 66.279450, 27.686959],
          [52.216950, 25.135531]).then((value) {
    print(value.list);
  }).catchError((error) {
    print("error $error");
  });
}
