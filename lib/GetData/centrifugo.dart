import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/CreateOrderModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


Future<String> getCentrifugoToken() async {
  await CreateOrder.sendRefreshToken();
  var url = 'https://notifier.apis.stage.faem.pro/api/v2/connectiontoken';
  var response = await http.get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'Source':'ios_client_app_1',
    "ServiceName": 'faem_food',
    'Authorization':'Bearer ' + authCodeData.token
  });
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    return jsonResponse['token'];
  } else {
    print('Request failed with status: ${response.statusCode}.');
    return '';
  }
}