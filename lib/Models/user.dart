import 'CartDataModel.dart';
import 'order.dart';

class User{
  bool isLoggedIn;
  String name;
  final List<Order> orders;
  CartDataModel cartDataModel;
  String phone;

  User({
    this.isLoggedIn = true,
    this.name,
    this.orders,
    this.cartDataModel,
    this.phone
  });
}