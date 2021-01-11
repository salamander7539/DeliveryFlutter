import 'dart:convert';
import 'package:faem_app/Models/NecessaryAddressModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


Future<NecessaryAddressData> loadFindAddress(double lat, double long) async {
  NecessaryAddressData necessaryAddressData = null;
  var json_request = jsonEncode({
    "lat": lat,
    "long": long
  });
  var url = 'https://crm.apis.stage.faem.pro/api/findaddress';
  var response = await http.post(url, body: json_request, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    necessaryAddressData = new NecessaryAddressData.fromJson(jsonResponse);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  return necessaryAddressData;
}