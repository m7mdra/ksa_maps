import 'package:flutter/material.dart';

class LocationButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LocationButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var radius = BorderRadius.circular(100);
    return Tooltip(
      message: "Go to my location",
      child: Card(
        margin: const EdgeInsets.all(16),
        child: InkWell(
          child: const Padding(
            padding: EdgeInsets.all(14.0),
            child: Icon(Icons.gps_fixed),
          ),
          onTap: onTap,
          borderRadius: radius,
        ),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    );
  }
}
