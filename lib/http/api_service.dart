import 'package:flutter/cupertino.dart';

import 'api_constant.dart';
import 'handle_request.dart';

class ApiService {
  final BuildContext context;

  ApiService(this.context);

  Future<void> userLogin(String email, String password,
      ResponseCallback callback) async {
    var url = '${ApiConstants.baseUrl}${ApiConstants.userLogin}';
    var body = {
      'email': email,
      'password': password,
    };
    await HandleRequest(context)
        .handleRequest('POST', url, "", false, body: body, callback: callback);
  }
}
