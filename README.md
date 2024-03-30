This is a generic packages to handle all api requests in all your projects with the most simple way.

## Features
 
 1. Handle all your network in the simplest way
 
 2. Easy To Use

## Usage

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
