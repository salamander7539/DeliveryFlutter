import 'dart:convert';
import 'package:faem_app/data/data.dart';
import 'package:faem_app/Models/RestaurantDataItems.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Future<RestaurantDataItems> loadOrderItems() async {
  RestaurantDataItems restaurantDataItems1 = null;
  var url = 'https://client.apis.stage.faem.pro/api/v2/orders';
  var response = await http.post(url, body: jsonEncode({
    "callback_phone": "+5556",
    "increased_fare": 25,
    "comment": "Просит побыстрей",
    "products_input": [
      {
        "uuid": "ec780939-fb4f-4685-b356-d4cc794dd621",
        "variat_uuid": "9c169536-75b6-11ea-bc55-0242ac130003",
        "toppings_uuid": [
          "some_id"
        ],
        "number": 3
      }
    ],
    "routes": [
      {
        "unrestricted_value": "Наш супермаркет Х.Мамсурова, Мамсурова Хаджи 42",
        "value": "Наш супермаркет Х.Мамсурова",
        "country": "",
        "region": "",
        "region_type": "",
        "city": "Владикавказ",
        "city_type": "",
        "street": "Хаджи Мамсурова",
        "street_type": "",
        "street_with_type": "",
        "house": "42",
        "out_of_town": false,
        "house_type": "",
        "accuracy_level": 0,
        "radius": 10000,
        "comment": "к ржавой калитке",
        "lat": 43.036274,
        "lon": 44.655212
      },
    ],
    "service_uuid": "44db4a2b-c33b-4323-9ee7-7b4864179192"
  }), headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    restaurantDataItems1 = new RestaurantDataItems.fromJson(jsonResponse);
    restaurantDataItems = restaurantDataItems1;
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  return restaurantDataItems1;
}