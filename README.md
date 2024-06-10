This is a generic packages to handle all api requests in all your projects with the most simple way.

## Features
 
 1. Handle all your network in the simplest way
 
 2. Easy To Use

## Install 
add those lines to your pubspec.yaml

```shell
  flutter_dio_network_manager:
    git:
      url: https://github.com/MohAmmedEssam/flutter_dio_network_manager
      ref: main
```

## Usage
### Using Builder design pattern
make this class to handle your next requests

```shell
// Builder for BaseClientGenerator
class RequestBuilder extends BaseClientGenerator {
  String _path = '';
  String _method = 'GET';
  String _baseURL = 'http://127.0.0.1:3000/api/';
  Map<String, dynamic>? _body;
  Map<String, dynamic>? _query;
  Map<String, dynamic>? _header = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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

  RequestBuilder setHeader(Map<String, dynamic>? header) {
    _header = header;
    return this;
  }

  @override
  String get path => _path;
  @override
  String get method => _method;
  @override
  String get baseURL => _baseURL;
  @override
  Map<String, dynamic>? get body => _body;
  @override
  Map<String, dynamic>? get query => _query;
  @override
  Map<String, dynamic>? get header => _header;
}
```
```shell
void login(Map<String, dynamic>? params) async {
  final request = RequestBuilder()
      .setPath('login')
      .setMethod('POST')
      .setBody(params);

  NetworkExecuter.execute(
    route: request,
    isLoading: (loading) {},
    onError: (message) {},
    callback: (response) {},
  );
}
```
### Another Way

### Needed Extension
make this extension to handle your next requests

```shell
class APIClient extends BaseClientGenerator {

  APIClient();

  @override
  String get baseURL => 'http://127.0.0.1/'; // add your base URL here

  @override
  Map<String, dynamic> get header => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
         // add your custom headers here
      };
}
```

### Example Request
define your request specs here 

```shell
class LoginClient extends APIClient {
  final Map<String, dynamic> params;

  LoginClient({required this.params});

  @override
  String get path => 'login';

  @override
  String get method => 'POST';

  @override
  dynamic get body => params;
}
```

### Base controller if using GetX
Base class controller all you other controller should inherit from it.

```shell
class AppController extends GetxController {
  request(
      {required BaseClientGenerator route,
      void Function(bool)? isLoading,
      required void Function(Map<dynamic, dynamic>?) callback}) {
    NetworkExecuter.execute(
        route: route,
        isLoading: isLoading,
        onNotAuth: () {
            
        },
        onError: (message) {

        },
        callback: callback);
  }
}

class LoginController extends AppController {
  login(Map<String, dynamic> params) {
    request(
        route: LoginClient(params: params),
        isLoading: (isLoading) {
            
        },
        callback: (response) {
          var model = LoginReponse.fromJson(response?['data']);
        });
  }
}
```

## Additional information
Provided By Mohammed Essam
