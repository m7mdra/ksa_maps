import 'package:ksa_maps/data/model/query_result.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

extension CoordinatesToLatLng on QueryResult {
  LatLng coordinates() => LatLng(lat, lng);

  List<double> latLng() => [lat, lng];
  List<double> lngLat() => [lng, lat];
}
