import 'dart:convert';
import 'dart:io';
import 'package:bestlocation/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert' as convert;

enum HttpMethod { get, post, put, delete, patch }

class ApiService {
  static dynamic _invoke(
      {required String endPoint,
      required HttpMethod method,
      Map<String, dynamic>? query,
      bool decode = true,
      Map<String, dynamic>? body}) async {
    Uri uri = Uri.parse(
            "https://67260d97302d03037e6c372b.mockapi.io/api/Location$endPoint")
        .replace(queryParameters: query);
    Map<String, String> header = <String, String>{};
    late http.Response response;
    switch (method) {
      case HttpMethod.get:
        response = await http.get(uri, headers: header);
        debugPrint('get ${response.statusCode}');
        break;
      case HttpMethod.post:
        header["Content-Type"] = "application/json; charset=UTF-8";
        response = await http.post(uri,
            headers: header, body: convert.jsonEncode(body));
        debugPrint('post ${response.statusCode}');
        break;
      case HttpMethod.put:
        header["Content-Type"] = "application/json; charset=UTF-8";
        response = await http.put(uri,
            headers: header, body: convert.jsonEncode(body));
        break;
      case HttpMethod.delete:
        response = await http.delete(uri,
            headers: header, body: convert.jsonEncode(body));
        break;
      case HttpMethod.patch:
        header["Content-Type"] = "application/json; charset=UTF-8";
        response = await http.patch(uri,
            headers: header, body: convert.jsonEncode(body));
        break;
    }
    if ([200, 201, 204].contains(response.statusCode)) {
     

      return convert.jsonDecode(response.body);
    } else {
      throw HttpException(
          "Server respond with ${response.statusCode} http code and body = ${convert.jsonDecode(response.body)["message"]} ");
    }
  }

  static Future<dynamic> get({required endPoint, Map<String, dynamic>? query}) {
    return _invoke(endPoint: endPoint, method: HttpMethod.get, query: query);
  }

  static Future<dynamic> post(
      {required endPoint,
      Map<String, dynamic>? body,
      Map<String, dynamic>? query,
      bool decode = true}) {
    return _invoke(
        endPoint: endPoint,
        method: HttpMethod.post,
        query: query,
        body: body,
        decode: decode);
  }

  static dynamic patch(
      {required endPoint,
      Map<String, dynamic>? body,
      Map<String, dynamic>? query}) {
    return _invoke(
        endPoint: endPoint, method: HttpMethod.patch, query: query, body: body);
  }

  static dynamic put({required endPoint, Map<String, dynamic>? body}) {
    return _invoke(endPoint: endPoint, method: HttpMethod.put, body: body);
  }

  static dynamic delete(endPoint,
      {Map<String, dynamic>? query, Map<String, dynamic>? body}) {
    return _invoke(
        endPoint: endPoint,
        method: HttpMethod.delete,
        query: query,
        body: body);
  }
}
