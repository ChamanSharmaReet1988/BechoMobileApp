import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

typedef ResponseCallback = void Function(String responseBody, {bool isError});

class HandleRequest {
  final BuildContext context;

  HandleRequest(this.context);

  Future<void> handleRequest(
      String method,
      String url,
      String token,
      bool authRequired, {
        Map<String, dynamic>? body,
        ResponseCallback? callback,
      }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (authRequired) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;

    try {
      switch (method) {
        case 'POST':
          response = await http
              .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
        case 'PUT':
          response = await http
              .put(Uri.parse(url), headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
        case 'GET':
          response = await http
              .get(Uri.parse(url), headers: headers)
              .timeout(const Duration(seconds: 10));
          break;
        case 'DELETE':
          response = await http
              .delete(Uri.parse(url), headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
        default:
          throw Exception('Invalid HTTP method');
      }

      if (response.statusCode == 200) {
        if (callback != null) {
          callback(response.body, isError: false);
        }
      } else if (response.statusCode == 302) {
        String location = response.headers['location'] ?? 'Unknown location';
        String redirectMessage = 'Redirected to $location';
        if (callback != null) {
          callback(redirectMessage, isError: true);
        }
      } else {
        if (callback != null) {
          callback(_extractErrorMessage(response.body, response.statusCode), isError: true);
        }
      }
    } catch (e) {
      String errorMessage = 'An error occurred: $e';
      if (callback != null) {
        callback(errorMessage, isError: true);
      }
    }
  }

  String _extractErrorMessage(String responseBody, int statusCode) {
    try {
      final Map<String, dynamic> json = jsonDecode(responseBody);
      if (json.containsKey('message')) {
        return json['message'];
      } else if (json.containsKey('errors')) {
        return json['errors'].values.expand((v) => v).join(', ');
      }
    } catch (e) {
      return _getErrorMessage(statusCode);
    }
    return _getErrorMessage(statusCode);
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Unauthorized. Please check your credentials.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      case 302:
        return 'Resource has been moved.';
      default:
        return 'Unexpected error occurred.';
    }
  }
}