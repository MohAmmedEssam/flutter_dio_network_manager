import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

import '../webSaver/web_file_saver_factory.dart';

abstract class BaseClientGenerator {
  const BaseClientGenerator();
  String get path => '';
  String get method => 'GET';
  String get baseURL => '';
  dynamic get body => null;
  Map<String, dynamic>? get query => null;
  Map<String, dynamic>? get header => {};
  int? get sendTimeout => 30000;
  int? get receiveTimeOut => 30000;
}

class NetworkCreator {
  static var shared = NetworkCreator();
  final Dio _client = Dio(BaseOptions())
    ..interceptors.addAll(
      kDebugMode
          ? [
              PrettyDioLogger(
                requestHeader: true,
                requestBody: true,
                responseBody: true,
                responseHeader: false,
                error: true,
                compact: true,
                maxWidth: 90,
              ),
            ]
          : [],
    );

  Dio get client =>
      _client; // <-- Add this getter to add interceptors from your app

  Future<Response> request({required BaseClientGenerator route}) {
    final rawData = route.body;
    final data = rawData is Map<String, dynamic>
        ? (Map<String, dynamic>.from(rawData)
          ..removeWhere((key, value) => value == null))
        : rawData;
    final query = route.query != null
        ? (Map<String, dynamic>.from(route.query!)
          ..removeWhere((key, value) => value == null))
        : null;

    return _client.fetch(
      RequestOptions(
        baseUrl: route.baseURL,
        headers: route.header,
        method: route.method,
        path: route.path,
        queryParameters: query,
        data: data,
        sendTimeout: Duration(milliseconds: route.sendTimeout ?? 3000),
        receiveTimeout: Duration(milliseconds: route.receiveTimeOut ?? 3000),
        validateStatus: (statusCode) => (statusCode != null &&
            statusCode >= HttpStatus.ok &&
            statusCode <= HttpStatus.multipleChoices),
      ),
    );
  }
}

extension NetworkCreatorDownload on NetworkCreator {
  Future<dynamic> download({
    required BaseClientGenerator route,
    required String savePath,
    void Function(int received, int total)? onProgress,
  }) async {
    final fullUrl = '${route.baseURL}${route.path}';
    final headers = route.header;

    if (kIsWeb) {
      final response = await _client.get<List<int>>(
        fullUrl,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          sendTimeout: Duration(milliseconds: route.sendTimeout ?? 3000),
          receiveTimeout: Duration(milliseconds: route.receiveTimeOut ?? 3000),
        ),
        onReceiveProgress: onProgress,
      );

      if (response.data == null) throw Exception("No data to download.");
      return await _getSavePathWeb(
        Uint8List.fromList(response.data!),
        savePath,
      );
    } else {
      return await _client.download(
        fullUrl,
        savePath,
        options: Options(
          headers: headers,
          sendTimeout: Duration(milliseconds: route.sendTimeout ?? 3000),
          receiveTimeout: Duration(milliseconds: route.receiveTimeOut ?? 3000),
        ),
        onReceiveProgress: onProgress,
      );
    }
  }
}

class NetworkExecuter {
  static execute({
    required BaseClientGenerator route,
    required void Function(String) onError,
    void Function(bool)? isLoading,
    void Function()? onNotAuth,
    required void Function(Map<dynamic, dynamic>?) callback,
  }) async {
    try {
      isLoading?.call(true);
      var response = await NetworkCreator.shared.request(route: route);
      isLoading?.call(false);
      callback(response.data);
    } on DioException catch (error) {
      isLoading?.call(false);
      if ((error.type == DioExceptionType.connectionError) ||
          (error.type == DioExceptionType.connectionTimeout)) {
        onError('No Internet Connection');
      } else {
        onError(_extractErrorMessage(error));
        if (error.response?.statusCode == 401) {
          onNotAuth?.call();
        }
      }
    } catch (error) {
      isLoading?.call(false);
      onError(error.toString());
    }
  }

  static download({
    required BaseClientGenerator route,
    required String fileName,
    required void Function(String) onError,
    void Function(bool)? isLoading,
    void Function()? onNotAuth,
    required void Function(String) callback,
  }) async {
    try {
      isLoading?.call(true);
      final savePath = await _getSavePath(fileName);
      await NetworkCreator.shared.download(
        route: route,
        savePath: savePath,
        onProgress: (received, total) {
          isLoading?.call(received != total);
        },
      );
      isLoading?.call(false);
      callback(savePath);
    } on DioException catch (error) {
      isLoading?.call(false);
      if ((error.type == DioExceptionType.connectionError) ||
          (error.type == DioExceptionType.connectionTimeout)) {
        onError('No Internet Connection');
      } else {
        onError(_extractErrorMessage(error));
        if (error.response?.statusCode == 401) {
          onNotAuth?.call();
        }
      }
    } catch (error) {
      isLoading?.call(false);
      onError(error.toString());
    }
  }
}

String _extractErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['message'] != null) {
    return data['message'].toString();
  }
  return error.response?.statusMessage ?? error.toString();
}

Future<String> _getSavePath(String filename) async {
  if (kIsWeb) return filename;
  Directory directory;
  try {
    directory = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  } catch (_) {
    directory = await getApplicationDocumentsDirectory();
  }
  return '${directory.path}/$filename';
}

Future<String> _getSavePathWeb(Uint8List bytes, String filename) async {
  return await webFileSaver.save(bytes, filename);
}
