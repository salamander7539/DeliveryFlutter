import 'dart:convert';
import 'package:device_id/device_id.dart';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/AuthCode.dart';
import 'package:faem_app/Models/centrifugo.dart';
import 'package:faem_app/Models/firebase_notification_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class NecessaryDataForAuth{
  String device_id;
  String phone_number;
  String refresh_token;
  String name;
  static NecessaryDataForAuth _necessaryDataForAuth;

  NecessaryDataForAuth({
    this.device_id,
    this.phone_number,
    this.refresh_token,
    this.name
  });

  static Future<NecessaryDataForAuth> getData() async{
  //    await Future.delayed(Duration(seconds: 4), () {});
    if(_necessaryDataForAuth != null)
      return _necessaryDataForAuth;
    String device_id = await DeviceId.getID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone_number = prefs.getString('phone_number');
    String refresh_token = prefs.getString('refresh_token');
    String name = prefs.getString('name');
    NecessaryDataForAuth result = new NecessaryDataForAuth(device_id: device_id, phone_number: phone_number, refresh_token: refresh_token, name: name);
    refresh_token = await refreshToken(refresh_token);
    result.refresh_token = refresh_token;
    _necessaryDataForAuth = result;
    if(refresh_token != null){
//      await new FirebaseNotifications().setUpFirebase();
      await Centrifugo.connectToServer();
      await saveData();
    }

    print('1');
    return result;
  }

  static Future saveData() async{
    String phone_number = _necessaryDataForAuth.phone_number;
    String refresh_token = _necessaryDataForAuth.refresh_token;
    String name = _necessaryDataForAuth.name;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phone_number', phone_number);
    prefs.setString('refresh_token',refresh_token);
    prefs.setString('name',name);
  }

  static Future<String> refreshToken(String refresh_token) async {
    String result = null;
    var url = 'https://client.apis.stage.faem.pro/api/v2/auth/refresh';
    var response = await http.post(url, body: jsonEncode({"refresh": refresh_token}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      authCodeData = AuthCodeData.fromJson(jsonResponse);
      result = authCodeData.refresh_token;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return result;
  }

  static Future clear() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _necessaryDataForAuth = null;
    necessaryDataForAuth = null;
  }
}