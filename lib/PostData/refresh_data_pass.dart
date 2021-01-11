import 'dart:convert';
import 'package:faem_app/Models/AuthCode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


Future<AuthCodeData> loadRefreshData(String device_id, int code) async {
  AuthCodeData authCodeData = null;
  var json_request = jsonEncode({
    "refresh": "7c9fc3d1-d681-4c2b-ada1-6ad8a7952d43"
  });
  var url = 'https://client.apis.stage.faem.pro/api/v2/auth/refresh';
  var response = await http.post(url, body: json_request, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    authCodeData = new AuthCodeData.fromJson(jsonResponse);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  return authCodeData;
}