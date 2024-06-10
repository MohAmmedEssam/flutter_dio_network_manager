library flutter_dio_network_manager;

import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'dart:io';

abstract class BaseClientGenerator {
  const BaseClientGenerator();
  String get path => '';
  String get method => 'GET';
  String get baseURL => '';
  Map<String, dynamic>? get body => null;
  Map<String, dynamic>? get query => null;
  Map<String, dynamic>? get header => {};
  int? get sendTimeout => 30000;
  int? get receiveTimeOut => 30000;
}

class NetworkConnectivity {
  static Future<bool> get status async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }
}

class NetworkCreator {
  static var shared = NetworkCreator();
  final Dio _client = Dio(BaseOptions())
    ..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

  Future<Response> request({required BaseClientGenerator route}) {
    return _client.fetch(RequestOptions(
        baseUrl: route.baseURL,
        headers: route.header,
        method: route.method,
        path: route.path,
        queryParameters: route.query
          ?..removeWhere((key, value) => value == null),
        data: route.body?..removeWhere((key, value) => value == null),
        sendTimeout: Duration(milliseconds: route.sendTimeout ?? 3000),
        receiveTimeout: Duration(milliseconds: route.receiveTimeOut ?? 3000),
        validateStatus: (statusCode) => (statusCode! >= HttpStatus.ok &&
            statusCode <= HttpStatus.multipleChoices)));
  }
}

class NetworkExecuter {
  static execute(
      {required BaseClientGenerator route,
      required void Function(String) onError,
      void Function(bool)? isLoading,
      void Function()? onNotAuth,
      required void Function(Map<dynamic, dynamic>?) callback}) async {
    // Check Network Connectivity
    if (await NetworkConnectivity.status) {
      try {
        isLoading != null ? isLoading(true) : null;
        var response = await NetworkCreator.shared.request(route: route);
        isLoading != null ? isLoading(false) : null;
        callback(response.data);
        // NETWORK ERROR
      } on DioException catch (error) {
        isLoading != null ? isLoading(false) : null;
        onError(error.response?.data['message'] ??
            error.response?.statusMessage ??
            error.toString());
        if (error.response?.statusCode == 401) {
          onNotAuth != null ? onNotAuth() : null;
        }
      } catch (error) {
        isLoading != null ? isLoading(false) : null;
        onError(error.toString());
      }
      // No Internet Connection
    } else {
      onError('No Internet Connection');
    }
  }
}
