import 'dart:math';

import 'package:ksa_maps/data/model/query_result.dart';

enum RouteType { start, end, stop }

class RoutePoint implements Comparable<RoutePoint>{
  QueryResult? locationPoint;
  RouteType routeType;
  late double id;

  RoutePoint({this.locationPoint, required this.routeType})
      : id = Random().nextDouble();


  @override
  String toString() {
    return 'RoutePoint{locationPoint: $locationPoint, routeType: $routeType}';
  }

  @override
  int compareTo(RoutePoint other) {
   return locationPoint?.lat.compareTo(other.locationPoint?.lat ?? 0) ?? 0;
  }
}

extension RoutePointExtension on RoutePoint {
  bool didSetLocation() => locationPoint != null;
}
