class RouteResponse {
  RouteResponse({
    required this.code,
    required this.routes,
    required this.waypoints,
  });
  late final String code;
  late final List<Routes> routes;
  late final List<Waypoints> waypoints;

  RouteResponse.fromJson(Map<String, dynamic> json){
    code = json['code'];
    routes = List.from(json['routes']).map((e)=>Routes.fromJson(e)).toList();
    waypoints = List.from(json['waypoints']).map((e)=>Waypoints.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['code'] = code;
    _data['routes'] = routes.map((e)=>e.toJson()).toList();
    _data['waypoints'] = waypoints.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Routes {
  Routes({
    required this.geometry,
    required this.legs,
    required this.weightName,
    required this.weight,
    required this.duration,
    required this.distance,
  });
  late final String geometry;
  late final List<Legs> legs;
  late final String weightName;
  late final num weight;
  late final num duration;
  late final num distance;

  Routes.fromJson(Map<String, dynamic> json){
    geometry = json['geometry'];
    legs = List.from(json['legs']).map((e)=>Legs.fromJson(e)).toList();
    weightName = json['weight_name'];
    weight = json['weight'];
    duration = json['duration'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['geometry'] = geometry;
    _data['legs'] = legs.map((e)=>e.toJson()).toList();
    _data['weight_name'] = weightName;
    _data['weight'] = weight;
    _data['duration'] = duration;
    _data['distance'] = distance;
    return _data;
  }
}

class Legs {
  Legs({
    required this.steps,
    required this.summary,
    required this.weight,
    required this.duration,
    required this.distance,
  });
  late final List<Steps> steps;
  late final String summary;
  late final num weight;
  late final num duration;
  late final num distance;

  Legs.fromJson(Map<String, dynamic> json){
    steps = List.from(json['steps']).map((e)=>Steps.fromJson(e)).toList();
    summary = json['summary'];
    weight = json['weight'];
    duration = json['duration'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['steps'] = steps.map((e)=>e.toJson()).toList();
    _data['summary'] = summary;
    _data['weight'] = weight;
    _data['duration'] = duration;
    _data['distance'] = distance;
    return _data;
  }
}

class Steps {
  Steps({
    required this.geometry,
    required this.maneuver,
    required this.mode,
    required this.drivingSide,
    required this.name,
    required this.intersections,
    required this.weight,
    required this.duration,
    required this.distance,
    required this.instruction,
  });
  late final String geometry;
  late final Maneuver maneuver;
  late final String mode;
  late final String drivingSide;
  late final String name;
  late final List<Intersections> intersections;
  late final num? weight;
  late final num? duration;
  late final num? distance;
  late final String instruction;

  Steps.fromJson(Map<String, dynamic> json){
    geometry = json['geometry'];
    maneuver = Maneuver.fromJson(json['maneuver']);
    mode = json['mode'];
    drivingSide = json['driving_side'];
    name = json['name'];
    intersections = List.from(json['intersections']).map((e)=>Intersections.fromJson(e)).toList();
    weight = json['weight'];
    duration = json['duration'];
    distance = json['distance'];
    instruction = json['instruction'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['geometry'] = geometry;
    _data['maneuver'] = maneuver.toJson();
    _data['mode'] = mode;
    _data['driving_side'] = drivingSide;
    _data['name'] = name;
    _data['intersections'] = intersections.map((e)=>e.toJson()).toList();
    _data['weight'] = weight;
    _data['duration'] = duration;
    _data['distance'] = distance;
    _data['instruction'] = instruction;
    return _data;
  }
}

class Maneuver {
  Maneuver({
    required this.bearingAfter,
    required this.bearingBefore,
    required this.location,
    required this.type,
  });
  late final int bearingAfter;
  late final int bearingBefore;
  late final List<double> location;
  late final String type;

  Maneuver.fromJson(Map<String, dynamic> json){
    bearingAfter = json['bearing_after'];
    bearingBefore = json['bearing_before'];
    location = List.castFrom<dynamic, double>(json['location']);
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['bearing_after'] = bearingAfter;
    _data['bearing_before'] = bearingBefore;
    _data['location'] = location;
    _data['type'] = type;
    return _data;
  }
}

class Intersections {
  Intersections({
    required this.out,
    required this.bearings,
    required this.location,
  });
  late final int? out;
  late final List<int> bearings;
  late final List<double> location;

  Intersections.fromJson(Map<String, dynamic> json){
    out = json['out'];
    bearings = List.castFrom<dynamic, int>(json['bearings']);
    location = List.castFrom<dynamic, double>(json['location']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['out'] = out;
    _data['bearings'] = bearings;
    _data['location'] = location;
    return _data;
  }
}

class Waypoints {
  Waypoints({
    required this.hint,
    required this.distance,
    required this.name,
    required this.location,
  });
  late final String hint;
  late final num distance;
  late final String name;
  late final List<double> location;

  Waypoints.fromJson(Map<String, dynamic> json){
    hint = json['hint'];
    distance = json['distance'];
    name = json['name'];
    location = List.castFrom<dynamic, double>(json['location']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['hint'] = hint;
    _data['distance'] = distance;
    _data['name'] = name;
    _data['location'] = location;
    return _data;
  }
}