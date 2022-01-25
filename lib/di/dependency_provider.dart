import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:ksa_maps/data/data.dart';
import 'package:ksa_maps/data/map_data_repository.dart';

GetIt _registrar = GetIt.instance;
const kAccessKey =
    "15b07b3081c5b96eba9ebbe1d31e929deb757ea242d46853fed3fa85bb4fe02a2db2e6f85390316d63f473bf3a2fc2768e62efebac6e30f08cc8c80429cec482";

class D {
  D._();

  static build() async {
    // var sharedPreference = await SharedPreferences.getInstance();

    var options = BaseOptions(
        baseUrl: "https://ksamaps.com/api/",
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // queryParameters: {'lang': sharedPreference.getString('lang') ?? 'en'},
        connectTimeout: 30000);

    var client = Dio(options);
    if (kDebugMode) {
      client.interceptors.add(LogInterceptor(
        error: true,
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
      ));
    }
    // client.interceptors.add(KeyInterceptor());
    _registrar.registerSingleton(client);
    _registrar.registerSingleton<MapDataRepository>(MapDataClient(client));
  }

  static T provide<T extends Object>() {
    return _registrar.get<T>();
  }
}

class KeyInterceptor extends Interceptor {
  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.queryParameters.addAll({"key": kAccessKey});
    handler.next(options);
  }
}
