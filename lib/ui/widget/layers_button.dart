import 'package:flutter/material.dart';

class LayersButton extends StatelessWidget {
  final VoidCallback? onTap;

  const LayersButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var radius = BorderRadius.circular(100);
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        child: const Padding(
          padding: EdgeInsets.all(14.0),
          child: Icon(Icons.layers),
        ),
        onTap: onTap,
        borderRadius: radius,
      ),
      shape: RoundedRectangleBorder(borderRadius: radius),
    );
  }
}
