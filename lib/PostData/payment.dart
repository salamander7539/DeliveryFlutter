import 'dart:convert';

import 'package:faem_app/Models/PaymentModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../data/data.dart';
import '../Models/CreateOrderModel.dart';


class Payment{

  static Future<PaymentRegisterWithVerification> registerCard(String order_uuid, String receiver) async {

    PaymentRegisterWithVerification paymentRegisterWithVerification = null;
    var json_request = jsonEncode({
      "order_uuid": order_uuid,
      "receiver": receiver
    });
    await CreateOrder.sendRefreshToken();
    var url = 'https://billing.apis.stage.faem.pro/api/v2/client/bank_cards';
    var response = await http.post(url, body: json_request, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'ServiceName':'faem_food',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      paymentRegisterWithVerification = new PaymentRegisterWithVerification.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return paymentRegisterWithVerification;
  }

  static Future<PaymentRegisterWithoutVerification> approveClientCard(String order_uuid, String receiver) async {

    PaymentRegisterWithoutVerification paymentRegisterWithoutVerification = null;
    var json_request = jsonEncode({
      "order_uuid": order_uuid,
      "receiver": receiver
    });
    await CreateOrder.sendRefreshToken();
    var url = 'https://billing.apis.stage.faem.pro/api/v2/client/bank_cards/approve';
    var response = await http.post(url, body: json_request, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'ServiceName':'faem_food',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      paymentRegisterWithoutVerification = new PaymentRegisterWithoutVerification.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return paymentRegisterWithoutVerification;
  }


  static Future<String> getClientCards() async {
    //QuickMessages quickMessage = null;
    await CreateOrder.sendRefreshToken();
    var url = 'https://billing.apis.stage.faem.pro/api/v2/client/bank_cards';
    var response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      "ServiceName": 'faem_food',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(response.body + 'ALO');
      //quickMessage = QuickMessages.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body + 'ALO');
    //return quickMessage;
  }

  static Future<String> deleteClientCard() async {
    //QuickMessages quickMessage = null;
    await CreateOrder.sendRefreshToken();
    var url = 'https://billing.apis.stage.faem.pro/api/v2/client/bank_cards/{{bank_card_uuid}}';
    var response = await http.delete(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'ServiceName':'faem_food',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(response.body + 'ALO');
      //quickMessage = QuickMessages.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body + 'ALO');
    //return quickMessage;
  }
}