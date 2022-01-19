import 'package:ksa_maps/di/dependency_provider.dart';

class KsaMapsResources {
  static const kRasterSatelliteTileUrl =
      'https://ksamaps.com/api/satellite/{z}/{x}/{y}.png?key=$kAccessKey';
  static const kRasterSatelliteTileAttribution =
      'Map tiles by <a target="_top" rel="noopener" href="http://stamen.com">Stamen Design</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a target="_top" rel="noopener" href="http://openstreetmap.org">OpenStreetMap</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>';

  static const kVectorTrafficTileUrl =
      "https://ksamaps.com/api/traffic/{z}/{x}/{y}.pbf?key=$kAccessKey";
  static const kVectorTrafficTileAttribution = "Traffic: Data Source © TomTom";

  static const kStyleTilesUrl = "https://ksamaps.com/api/style?key=$kAccessKey";
}
