import 'package:flutter/material.dart';
import 'package:ksa_maps/ui/home/bloc/home/route.dart';
import 'package:ksa_maps/ui/widget/route_type.dart';

class RoutePlanningWidget extends StatelessWidget {
  final List<RoutePoint> routesPoint;
  final VoidCallback? onAddStartPointTap;
  final VoidCallback? onAddEndPointTap;
  final Function(RoutePoint)? onAddStopPointTap;
  final VoidCallback? onAddNewStopPointTap;
  final VoidCallback? onSearchClick;
  final VoidCallback? onClearClick;
  final Function(RoutePoint)? onDeleteStopPointTap;

  const RoutePlanningWidget(
      {Key? key,
        required this.routesPoint,
        this.onAddEndPointTap,
        this.onAddNewStopPointTap,
        this.onDeleteStopPointTap,
        this.onAddStartPointTap,
        this.onAddStopPointTap,
        this.onSearchClick,
        this.onClearClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var point = routesPoint[index];
                return GestureDetector(
                  onTap: () async {
                    switch (point.routeType) {
                      case RouteType.start:
                        onAddStartPointTap?.call();
                        break;
                      case RouteType.end:
                        onAddEndPointTap?.call();

                        break;
                      case RouteType.stop:
                        onAddStopPointTap?.call(point);
                        break;
                    }
                  },
                  child: Row(
                    children: [
                      RouteTypeWidget(routeType: point.routeType),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            point.locationPoint?.name ?? "",
                            maxLines: 1,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      Visibility(
                        child: IconButton(
                            onPressed: () {
                              onDeleteStopPointTap?.call(point);
                            },
                            icon: const Icon(Icons.delete_forever)),
                        visible: point.routeType == RouteType.stop,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        maintainInteractivity: false,
                      )
                    ],
                  ),
                );
              },
              itemCount: routesPoint.length),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                TextButton.icon(
                    onPressed: onAddNewStopPointTap,
                    label: const Text("Add new stop"),
                    icon: const Icon(Icons.add_circle_rounded)),
                const Spacer(),
                Text(
                    "${routesPoint.where((value) => value.routeType != RouteType.start).length} Stops")
              ]),
              Row(children: [
                Expanded(
                    flex: 2,
                    child: ElevatedButton(
                        onPressed: onSearchClick, child: const Text("Search"))),
                const SizedBox(width: 16),
                Expanded(
                    child: OutlinedButton(
                        onPressed: onClearClick, child: const Text("Clear"))),
              ])
            ],
          ),
        )
      ]),
    );
  }
}
