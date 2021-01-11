import 'dart:convert';
import 'package:faem_app/Models/InitialAddressModel.dart';
import 'package:faem_app/Models/amplitude.dart';
import 'package:faem_app/Models/last_addresses_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../Config/config.dart';
import '../PostData/necessary_address_data_pass.dart';
import '../data/data.dart';
import 'AuthCode.dart';
import 'CartDataModel.dart';
import 'NecessaryAddressModel.dart';
import 'ResponseData.dart';

class CreateOrder {
  InitialAddressModel address;
  String office;
  DestinationPoints restaurantAddress;
  String intercom;
  String entrance;
  String floor;
  String comment;
  String delivery;
  CartDataModel cartDataModel;
  Records restaurant;
  String payment_type;
  bool door_to_door;

  CreateOrder({
    this.address,
    this.office,
    this.restaurantAddress,
    this.intercom,
    this.entrance,
    this.floor,
    this.comment,
    this.delivery,
    this.cartDataModel,
    this.restaurant,
    this.payment_type,
    this.door_to_door
  });

  static Future<bool> sendRefreshToken() async {
    bool isSuccess = false;
    var url = 'https://client.apis.stage.faem.pro/api/v2/auth/refresh';
    var response = await http.post(
        url, body: jsonEncode({"refresh": authCodeData.refresh_token}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    print('ТУТ КЕФРЕЭ ' + authCodeData.refresh_token);
    if (response.statusCode == 200) {
      isSuccess = true;
      var jsonResponse = convert.jsonDecode(response.body);
      authCodeData = AuthCodeData.fromJson(jsonResponse);
      necessaryDataForAuth.refresh_token = authCodeData.refresh_token;
      NecessaryDataForAuth.saveData();
      //await sendFCMToken(FCMToken);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body);
    return isSuccess;
  }

  Future sendData() async {
    await sendRefreshToken();
    AmplitudeAnalytics.analytics.logEvent('make_order');
    print(authCodeData.token);
    var url = 'https://client.apis.stage.faem.pro/api/v2/orders';
    String commentCheck = comment;
    if(entrance != ''){
      commentCheck += '. Подъезд: ' + entrance + ',';
    }
    if(intercom != ''){
      commentCheck += ' Домофон: ' + intercom + ',';
    }
    if(floor != ''){
      commentCheck += ' Этаж: ' + floor + ',';
    }
    if(office != ''){
      commentCheck += ' Кв./Офис: ' + office;
    }
    var response = await http.post(url, body: jsonEncode({
      "callback_phone": currentUser.phone,
      "increased_fare": 25,
      "comment": commentCheck,
      "features_uuids": (door_to_door) ? [
        "8209935f-6251-4982-9b02-b2d642418b5e"
      ] : null,
      "products_input": cartDataModel.toServerJSON(),
      "routes": [
        restaurantAddress.toJson(),
        address.toJson()
      ],
      "payment_type": payment_type,
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
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body);
  }
}