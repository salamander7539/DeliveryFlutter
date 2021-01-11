import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/CreateOrderModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../Models/TicketModel.dart';

Future<TicketsList> getTicketsByFilter(int page, int limit, String clientPhone, {String status}) async {

  TicketsList serviceModel = null;
  await CreateOrder.sendRefreshToken();
  var url = (status == null) ? 'https://crm.apis.stage.faem.pro/api/v2/tickets/filter?page=$page&limit=$limit&clientphone=$clientPhone'
  : 'https://crm.apis.stage.faem.pro/api/v2/tickets/filter?page=$page&limit=$limit&clientphone=$clientPhone&status=$status';
  var response = await http.get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'Source':'ios_client_app_1',
    "ServiceName": 'faem_food',
    'Authorization':'Bearer ' + authCodeData.token
  });
  if (response.statusCode == 200) {

    print(response.body);
    var jsonResponse = convert.jsonDecode(response.body);
    serviceModel = TicketsList.fromJson(jsonResponse);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  print(response.body);
  return serviceModel;
}