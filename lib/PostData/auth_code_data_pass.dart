import 'dart:convert';
import 'package:faem_app/Models/AuthCode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future<AuthCodeData> loadAuthCodeData(String device_id, int code) async {

  AuthCodeData authCodeData = null;
  var json_request = jsonEncode({
    "device_id": device_id,
    "code": code
  });
  var url = 'https://client.apis.stage.faem.pro/api/v2/auth/verification';
  var response = await http.post(url, body: json_request, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    authCodeData = new AuthCodeData.fromJson(jsonResponse);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  print(response.body);
  return authCodeData;
}