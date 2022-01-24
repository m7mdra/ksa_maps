import 'package:ksa_maps/data/model/query_result.dart';

enum RouteType { start, end, stop }

class RoutePoint {
  QueryResult? locationPoint;
  RouteType routeType;

  RoutePoint({this.locationPoint, required this.routeType});
}
