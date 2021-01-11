import 'dart:convert';
import 'package:faem_app/Models/ResponseData.dart';
import 'package:faem_app/Models/RestaurantDataItems.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


Future<RestaurantDataItems> loadRestaurantItems(String uuid, String category, int page, int limit) async {
  RestaurantDataItems restaurantDataItems1 = null;
  print(uuid);
  var json_request = jsonEncode({
    "store_uuid": uuid,
    "category": category,
    "page": page,
    "limit": limit
  });
  if(category == ''){
    json_request = jsonEncode({
      "store_uuid": uuid,
      "page": page,
      "limit": limit
    });
  }
  var url = 'https://crm.apis.stage.faem.pro/api/v2/products';
  var response = await http.post(url, body: json_request, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  });
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    restaurantDataItems1 = new RestaurantDataItems.fromJson(jsonResponse);
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
  print(restaurantDataItems1);
  return restaurantDataItems1;
}

Future<RestaurantDataItems> loadAllRestaurantItems(Records restaurant) async {
  // Получаем количество еды в ресторане
  int recordsCount =
      (await loadRestaurantItems(restaurant.uuid, "", 1, 1)).records_count;
  if(recordsCount == 0)
    return new RestaurantDataItems(records_count: 0);  // Получаем всю еду в неотсортированном виде
  RestaurantDataItems result = await loadRestaurantItems(restaurant.uuid, "", 1, recordsCount);

  // Сортируем список еды
  result.records.sort((var a, var b) {
    int aCategoryIndex = restaurant.product_category.indexOf(a.category);
    int bCategoryIndex = restaurant.product_category.indexOf(b.category);
    return aCategoryIndex.compareTo(bCategoryIndex);
  });

  return result;
}