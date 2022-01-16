import 'package:flutter/material.dart';

class Button360View extends StatelessWidget {
  final VoidCallback? onTap;

  const Button360View({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var radius = BorderRadius.circular(100);
    return Tooltip(
      message: "360 view",
      child: Card(
        margin: const EdgeInsets.all(16),
        child: InkWell(
          child: const Padding(
            padding: EdgeInsets.all(14.0),
            child: Icon(Icons.threesixty),
          ),
          onTap: onTap,
          borderRadius: radius,
        ),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    );
  }
}
