import 'package:flutter/material.dart';

class MapZoomControls extends StatelessWidget {
  final VoidCallback? zoomInCallback;
  final VoidCallback? zoomOutCallback;

  const MapZoomControls({Key? key, this.zoomInCallback, this.zoomOutCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var borderRadius = BorderRadius.circular(24);
    var radius = const Radius.circular(24);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Tooltip(
            message: "Zoom in",
            child: InkWell(
              radius: 16,
                borderRadius: BorderRadius.only(topLeft: radius,topRight: radius),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.zoom_in),
                ),
                onTap: zoomInCallback),
          ),
          Container(
            height: 1,
            width: 40,
            color: Colors.grey.shade200,
          ),
          Tooltip(
            message: "Zoom out",
            child: InkWell(
                radius: 16,
                borderRadius: BorderRadius.only(bottomLeft: radius,bottomRight: radius),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.zoom_out),
                ),
                onTap: zoomOutCallback),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
