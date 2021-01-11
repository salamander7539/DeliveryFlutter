import 'dart:convert';
import 'dart:ffi';
import 'package:faem_app/Models/amplitude.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../data/data.dart';
import 'AuthCode.dart';
import 'CartDataModel.dart';
import 'ResponseData.dart';

class CreateOrderTakeAway {
  String address;
  DestinationPoints restaurantAddress;
  String comment;
  String delivery;
  CartDataModel cartDataModel;
  bool without_delivery;
  Records restaurant;

  CreateOrderTakeAway( {
    this.address,
    this.restaurantAddress,
    this.comment,
    this.delivery,
    this.cartDataModel,
    this.without_delivery,
    this.restaurant
  });

  sendRefreshToken() async{
    var url = 'https://client.apis.stage.faem.pro/api/v2/auth/refresh';
    var response = await http.post(url, body: jsonEncode({"refresh": authCodeData.refresh_token}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      authCodeData = AuthCodeData.fromJson(jsonResponse);
      //print(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body);
  }

  Future sendData() async {
    await sendRefreshToken();
    AmplitudeAnalytics.analytics.logEvent('make_order');
    print(authCodeData.token);
    var url = 'https://client.apis.stage.faem.pro/api/v2/orders';
    var response = await http.post(url, body: jsonEncode({
      "callback_phone": currentUser.phone,
      "increased_fare": 25,
      "comment": comment,
      "products_input": cartDataModel.toJson(),
      "without_delivery":true,
      "routes": [
        restaurantAddress.toJson(),
      ],
      "service_uuid": "6b73e9e3-927b-453c-81c4-dfae818291f4",
    }), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      "ServiceName": 'faem_food',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      http.Response suka = await http.get('https://client.apis.stage.faem.pro/api/v2/orders/' + jsonResponse['uuid'],
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Source':'ios_client_app_1',
            "ServiceName": 'faem_food',
            'Authorization':'Bearer ' + authCodeData.token
          });
      print(suka.body);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body);
  }
}