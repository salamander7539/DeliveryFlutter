import 'dart:convert';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/ChatHistoryModel.dart';
import 'package:faem_app/Models/CreateOrderModel.dart';
import 'package:faem_app/Models/QuickMessagesModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Chat{

  static Future<ChatHistoryModel> loadChatHistory(String order_uuid, String receiver) async {

    ChatHistoryModel chatHistoryModel = null;
    var json_request = jsonEncode({
      "order_uuid": order_uuid,
      "receiver": receiver
    });
    await CreateOrder.sendRefreshToken();
    var url = 'https://chat.apis.stage.faem.pro/api/v2/chat/history';
    var response = await http.post(url, body: json_request, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      "ServiceName": 'faem_food',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print('riiiiiiiiiiiiiiiiiiiiiiiiiiiiiiin');
      chatHistoryModel = new ChatHistoryModel.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body + 'sabeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeer');
    return chatHistoryModel;
  }


  static Future<ChatMessage> sendMessage(String order_uuid, String message, String receiver) async {

    ChatMessage chatMessage = null;
    var json_request = jsonEncode({
      "order_uuid": order_uuid,
      "message": message,
      "receiver": receiver
    });
    await CreateOrder.sendRefreshToken();
    var url = 'https://chat.apis.stage.faem.pro/api/v2/messages/new';
    var response = await http.post(url, body: json_request, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      "ServiceName": 'faem_food',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      chatMessage = new ChatMessage.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body);
    return chatMessage;
  }


  static Future<void> readMessage(List<String> messages_uuid) async {

    var json_request = jsonEncode({
      "messages_uuid": messages_uuid
    });
    await CreateOrder.sendRefreshToken();
    var url = 'https://chat.apis.stage.faem.pro/api/v2/messages/mark/read';
    var response = await http.post(url, body: json_request, headers: <String, String>{
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


  static Future<QuickMessages> getMessages() async {
    QuickMessages quickMessage = null;
    await CreateOrder.sendRefreshToken();
    var url = 'https://crm.apis.stage.faem.pro/api/v2/quickmessages';
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
      quickMessage = QuickMessages.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    print(response.body + 'ALO');
    return quickMessage;
  }
}