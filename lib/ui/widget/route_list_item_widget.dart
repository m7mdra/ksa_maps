import 'package:flutter/material.dart';
import 'package:ksa_maps/data/model/route_response.dart';

class RouteListItem extends StatelessWidget {
  final Function(Routes)? onTap;
  final bool selected;

  const RouteListItem({
    Key? key,
    this.onTap,
    required this.route,
    this.selected = false,
  }) : super(key: key);

  final Routes route;

  @override
  Widget build(BuildContext context) {
    var duration = Duration(seconds: route.duration.toInt());
    return ListTile(
      selected: selected,
      onTap: () {
        onTap?.call(route);
      },
      leading: Column(
        children: [
          Text(
            "${duration.inHours}:${duration.inMinutes}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Text(
            "Mins",
          ),
        ],
      ),
      title: Container(
        color: selected ? Colors.blue : Colors.blueGrey,
        width: MediaQuery.of(context).size.width,
        height: 4,
      ),
      trailing: Text("${(route.distance / 1000).toStringAsFixed(1)} KM"),
      subtitle: Text(route.legs.map((e) => e.summary).join(""), maxLines: 1),
    );
  }
}
