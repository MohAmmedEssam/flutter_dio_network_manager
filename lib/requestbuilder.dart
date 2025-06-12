import 'package:dio/dio.dart';
import 'flutter_dio_network_manager.dart';

// Files
class UploadFile {
  List<int>? bytes;
  String? path, name;

  UploadFile({this.bytes, this.path, this.name});
}

// Builder for BaseClientGenerator
class RequestBuilder extends BaseClientGenerator {
  String _path = '';
  String _method = 'GET';
  String _baseURL = '';
  dynamic _body;
  Map<String, dynamic>? _query;
  Map<String, dynamic>? _header = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Credentials': 'true',
  };

  RequestBuilder setMultipart(
    Map<String, dynamic> body,
    List<UploadFile> files,
  ) {
    _header?['Content-Type'] = 'multipart/form-data';

    final formDataMap = <String, dynamic>{};
    formDataMap.addAll(body);

    final List<MultipartFile> multipartFiles = [];

    for (var file in files) {
      if (file.bytes != null) {
        multipartFiles.add(
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        );
      } else if (file.path != null) {
        multipartFiles.add(
          MultipartFile.fromFileSync(file.path!, filename: file.name),
        );
      }
    }

    formDataMap['file'] = multipartFiles;

    _body = FormData.fromMap(formDataMap);
    return this;
  }

  RequestBuilder setPath(String path) {
    _path = path;
    return this;
  }

  RequestBuilder setMethod(String method) {
    _method = method;
    return this;
  }

  RequestBuilder setBaseURL(String baseURL) {
    _baseURL = baseURL;
    return this;
  }

  RequestBuilder setBody(dynamic body) {
    _body = body;
    return this;
  }

  RequestBuilder setQuery(Map<String, dynamic> query) {
    _query = query;
    return this;
  }

  RequestBuilder setHeader(Map<String, dynamic> header) {
    _header = header;
    return this;
  }

  RequestBuilder updateHeader(Map<String, dynamic> header) {
    _header = {...?_header, ...header}; // new keys overwrite old ones
    return this;
  }

  @override
  String get path => _path;
  @override
  String get method => _method;
  @override
  String get baseURL => _baseURL;
  @override
  dynamic get body => _body;
  @override
  Map<String, dynamic>? get query => _query;
  @override
  Map<String, dynamic>? get header => _header;
}
