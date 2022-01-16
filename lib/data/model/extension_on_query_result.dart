
import 'package:ksa_maps/data/model/query_result.dart';
import 'package:maplibre_gl/mapbox_gl.dart';


extension CoordinatesToLatLng on QueryResult {
  LatLng coordinates() => LatLng(lat ?? 0.0, lng ?? 0.0);
}
