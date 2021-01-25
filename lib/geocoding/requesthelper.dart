import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestHelper {

   static Future<dynamic> getRequest(url) async {
    try {

      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = response.body;
        var jsonData = jsonDecode(data);
        return jsonData;
      } else {
        return 'failed';
      }
    } catch (e) {
      return 'failed';
    }
  }
}
