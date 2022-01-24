import 'package:flutter/material.dart';
import 'package:ksa_maps/data/model/query_result.dart';
import 'package:ksa_maps/ui/home/route.dart';

class RouteTypeWidget extends StatelessWidget {
  final RouteType routeType;

  const RouteTypeWidget({Key? key, required this.routeType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff005CB5);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (routeType == RouteType.start)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2)),
          )
        else
          if (routeType == RouteType.end)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2)),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2)),
                ),
              ],
            )
          else
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2)),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2)),
                ),
              ],
            ),
      ],
    );
  }
}
