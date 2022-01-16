class QueryResultResponse {
  final List<QueryResult> list;

  QueryResultResponse(this.list);

  factory QueryResultResponse.fromJson(List<dynamic> json) =>
      QueryResultResponse(json.map((e) => QueryResult.fromJson(e)).toList());
}

class QueryResult {
  QueryResult({
    this.lat,
    this.lng,
    this.name,
    this.fullAddress,
    this.streetName,
    this.district,
    this.province,
    this.city,
    this.postalCode,
    this.pages,
    this.type,
  });

  final double? lat;
  final double? lng;
  final String? name;
  final String? fullAddress;
  final String? streetName;
  final String? district;
  final String? province;
  final String? city;
  final String? postalCode;
  final String? pages;
  final int? type;

  factory QueryResult.fromJson(Map<String, dynamic> json) => QueryResult(
        lat: json["lat"] ?? 0.0,
        lng: json["lng"] ?? 0.0,
        name: json["name"] ?? "",
        fullAddress: json["full_address"] ?? "",
        streetName: json["street_name"] ?? "",
        district: json["district"] ?? "",
        province: json["province"] ?? "",
        city: json["city"] ?? "",
        postalCode: json["postal_code"] ?? "",
        pages: json["pages"] ?? "",
        type: json["type"] ?? "",
      );

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "lng": lng,
      "name": name,
      "fullAddress": fullAddress,
      "streetName": streetName,
      "district": district,
      "province": province,
      "city": city,
      "postalCode": postalCode,
      "pages": pages,
      "type": type
    };
  }

  @override
  String toString() {
    return 'QueryResult{lat: $lat, lng: $lng, name: $name, fullAddress: $fullAddress}';
  }
}
