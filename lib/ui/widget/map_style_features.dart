import 'package:flutter/material.dart';

class MapStyleFeatures extends StatelessWidget {
  const MapStyleFeatures({
    Key? key,
    required this.satelliteAdded,
    required this.isTrafficEnabled,
    this.onNormalSelected,
    this.onTrafficToggle,
    this.onSatelliteSelected,
  }) : super(key: key);
  final VoidCallback? onTrafficToggle;
  final VoidCallback? onNormalSelected;
  final VoidCallback? onSatelliteSelected;
  final bool satelliteAdded;
  final bool isTrafficEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Map style',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ListTile(
            onTap: onNormalSelected,
            selected: !satelliteAdded,
            subtitle: Text('Map Data and APIs - THTC Maps'),
            leading: ClipRRect(
              child: Image.asset(
                "assets/image/map2.png",
                width: 50,
                height: 50,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text("Normal"),
          ),
          ListTile(
            onTap: onSatelliteSelected,
            selected: satelliteAdded,
            subtitle: const Text(
                'Imagery: Esri, Maxar, Earthstar Geographics, CNES/Airbus DS, USDA FSA, USGS, Aerogrid, IGN, IGP, and the GIS User Community'),
            leading: ClipRRect(
              child: Image.asset(
                "assets/image/map1.png",
                width: 50,
                height: 50,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text("Satellite"),
          ),
          const SizedBox(height: 16),
          const Text(
            'Map Features',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ListTile(
            onTap: onTrafficToggle,
            selected: isTrafficEnabled,
            subtitle: const Text("Traffic: Data Source © TomTom"),
            leading: ClipRRect(
              child: Image.asset(
                "assets/image/traffic.png",
                width: 50,
                height: 50,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            title: const Text("Traffic"),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
