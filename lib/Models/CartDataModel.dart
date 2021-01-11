import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

import 'order.dart';

class CartDataModel {
  List<Order> cart = new List<Order>();
  CartDataModel( {
    this.cart,
  });
  List<Map<String, dynamic>> toServerJSON(){
    List<Map<String, dynamic>> list = new List<Map<String, dynamic>>();
    cart.forEach((Order order) {
      List<String> toppingsUuid = null;
      if(order.food.toppings != null){
        toppingsUuid = new List<String>();
        order.food.toppings.forEach((element) {
          toppingsUuid.add(element.uuid);
        });
      }
      Map<String, dynamic> item =
          {
            "uuid": order.food.uuid,
            "variant_uuid": (order.food.variants != null) ? order.food.variants[0].uuid : null,
            "toppings_uuid": toppingsUuid,
            "number": order.quantity,
          };
      list.add(item);
    });
    return list;
  }

  List<Map<String, dynamic>> toJson(){
    List<Map<String, dynamic>> list = new List<Map<String, dynamic>>();
    cart.forEach((Order order) {
      List<dynamic> toppings;
      if(order.food.toppings != null){
        toppings = new List<dynamic>();
        order.food.toppings.forEach((element) {
          Map<String, dynamic> item = {
            'name': element.name,
            'uuid': element.uuid,
            'price': element.price,
            'comment': element.comment
          };
          toppings.add(item);
        });
      }
      Map<String, dynamic> item =
      {
        "uuid": order.food.uuid,
        "name": order.food.name,
        "variant_uuid": (order.food.variants != null) ? order.food.variants[0].uuid : null,
        "variant_name": (order.food.variants != null) ? order.food.variants[0].name : '',
        "toppings": toppings,
        "number": order.quantity,
        "price": order.food.price,
        "restaurant": order.restaurant.toJson(),
        "image": order.food.image
      };
      list.add(item);
    });
    return list;
  }

  void addItem(Order orderItem){
    bool flag = false;
    cart.forEach((element) {
      if(element.food.uuid == orderItem.food.uuid && element.food.variants == orderItem.food.variants && element.food.toppings == orderItem.food.toppings){
        element.quantity += orderItem.quantity;
        flag = true;
      }
    });
    if(!flag){
      cart.add(orderItem);
    }
  }

  Future saveData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', convert.jsonEncode(toJson()));
    if(cart != null && cart.length > 0)
      prefs.setString('restaurant', convert.jsonEncode(cart[0].restaurant.toJson()));
  }

   static Future<CartDataModel> getCart() async{
    var temp_cart = new CartDataModel(cart: new List<Order>());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('cart'))
      return temp_cart;
    var json_cart = convert.jsonDecode(prefs.getString('cart'));

    temp_cart = await CartDataModel.fromJson(json_cart);
    return temp_cart;
  }

   static Future<CartDataModel> fromJson(List<dynamic> parsedJson) async{

    List<Order> records = new List<Order>();
    parsedJson.forEach((value) {
      Order record = Order.fromJson(value);
      records.add(record);
    });

    return new CartDataModel(
      cart:records,
    );
  }
}