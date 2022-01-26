// To parse this JSON data, do
//
//     final mapFeature = mapFeatureFromJson(jsonString);

import 'dart:convert';

class MapFeature {
  MapFeature({
    required this.geometry,
    this.type,
    this.properties,
  });

  Geometry geometry;
  String? type;
  Properties? properties;

  factory MapFeature.fromRawJson(String str) => MapFeature.fromJson(json.decode(str));


  factory MapFeature.fromJson(Map<String, dynamic> json) => MapFeature(
    geometry: Geometry.fromJson(json["geometry"]),
    type: json["type"],
    properties: Properties.fromJson(json["properties"]),
  );

  @override
  String toString() {
    return 'MapFeature{geometry: $geometry, type: $type, properties: $properties}';
  }
}

class Geometry {
  Geometry({
    required this.type,
    this.coordinates,
  });

  String type;
  List<dynamic>? coordinates;

  factory Geometry.fromRawJson(String str) => Geometry.fromJson(json.decode(str));


  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    type: json["type"],
    coordinates: List<dynamic>.from(json["coordinates"].map((x) => x)),
  );

  @override
  String toString() {
    return 'Geometry{type: $type}';
  }
}

class Properties {
  Properties({
    this.catcod,
    this.name2,
    this.isfreeze,
    this.subcatcod,
    this.name1,
    this.fid1,
    this.alignRems,
    this.remarkAhm,
    this.dtrf,
    this.level,
    this.rdclass,
    this.formofway,
  });

  int? catcod;
  String? name2;
  int? isfreeze;
  String? subcatcod;
  String? name1;
  dynamic? fid1;
  int? alignRems;
  String? remarkAhm;
  String? dtrf;
  int? level;
  int? rdclass;
  int? formofway;

  factory Properties.fromRawJson(String str) => Properties.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    catcod: json["CATCOD"],
    name2: json["NAME2"],
    isfreeze: json["FREEZE"],
    subcatcod: json["SUBCATCOD"],
    name1: json["NAME1"],
    fid1: json["FID_1"],
    alignRems: json["ALIGN_REMS"],
    remarkAhm: json["REMARK_AHM"],
    dtrf: json["DTRF"],
    level: json["LEVEL"],
    rdclass: json["RDCLASS"],
    formofway: json["FORMOFWAY"],
  );

  @override
  String toString() {
    return 'Properties{name2: $name2, name1: $name1}';
  }

  Map<String, dynamic> toJson() => {
    "CATCOD": catcod,
    "NAME2": name2,
    "ISFREEZE": isfreeze,
    "SUBCATCOD": subcatcod,
    "NAME1": name1,
    "FID_1": fid1,
    "ALIGN_REMS": alignRems,
    "REMARK_AHM": remarkAhm,
    "DTRF": dtrf,
    "LEVEL": level,
    "RDCLASS": rdclass,
    "FORMOFWAY": formofway,
  };
}
