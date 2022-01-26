import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ksa_maps/data/model/route_response.dart';
import 'package:ksa_maps/ui/home/bloc/route/route_bloc.dart';
import 'package:ksa_maps/ui/widget/route_list_item_widget.dart';

class RoutesViewWidget extends StatefulWidget {
  final VoidCallback? onBackTap;
  final Function(Routes)? itemClickCallback;

  const RoutesViewWidget({Key? key, this.onBackTap, this.itemClickCallback})
      : super(key: key);

  @override
  State<RoutesViewWidget> createState() => _RoutesViewWidgetState();
}

class _RoutesViewWidgetState extends State<RoutesViewWidget> {
  var _selection;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: widget.onBackTap,
                    icon: const Icon(Icons.arrow_back)),
                const Text(
                  "Routes",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            BlocBuilder(
                builder: (context, state) {
                  if (state is RouteLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is RouteSuccess) {
                    var routes = state.response.routes;
                    return ListView.separated(
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var route = routes[index];
                        return RouteListItem(
                          route: route,
                          selected: _selection == route,
                          onTap: (route) {
                            widget.itemClickCallback?.call(route);
                            setState(() {
                              _selection = route;
                            });
                          },
                        );
                      },
                      itemCount: routes.length,
                    );
                  }
                  return Container();
                },
                bloc: context.read<RouteBloc>()),
          ],
        ),
      ),
    );
  }
}
