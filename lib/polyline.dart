import 'dart:math' as math;
import 'package:fixnum/fixnum.dart';

class PolylineCodec {
  PolylineCodec._();


  static List<List<num>> decode(String str, {int precision: 5}) {
    final List<List<num>> coordinates = [];

    var index = 0,
        lat = 0.0,
        lng = 0.0,
        shift = 0,
        result = 0,
        byte,
        latitudeChange,
        longitudeChange,
        factor = math.pow(10, precision);

    // Coordinates have variable length when encoded, so just keep
    // track of whether we've hit the end of the string. In each
    // loop iteration, a single coordinate is decoded.
    while (index < str.length) {
      // Reset shift, result, and byte
      byte = null;
      shift = 0;
      result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((Int32(byte) & Int32(0x1f)) << shift).toInt();
        shift += 5;
      } while (byte >= 0x20);

      latitudeChange =
          ((result & 1) != 0 ? ~(Int32(result) >> 1) : (Int32(result) >> 1))
              .toInt();

      shift = result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((Int32(byte) & Int32(0x1f)) << shift).toInt();
        shift += 5;
      } while (byte >= 0x20);

      longitudeChange =
          ((result & 1) != 0 ? ~(Int32(result) >> 1) : (Int32(result) >> 1))
              .toInt();

      lat += latitudeChange;
      lng += longitudeChange;

      coordinates.add([lat / factor, lng / factor]);
    }

    return coordinates;
  }

}
