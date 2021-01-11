import 'ResponseData.dart';
import 'RestaurantDataItems.dart';

class Order {
  Records restaurant;
  final FoodRecords food;
  int quantity;
  bool isSelected;
  final String date;


  Order({
    this.restaurant,
    this.food,
    this.date,
    this.isSelected = false,
    this.quantity,
  });

  factory Order.fromJson(Map<String, dynamic> parsedJson){
  print(parsedJson);
  var toppings_list = parsedJson['toppings'] as List;
  List<Toppings> toppingsList = null;
  if(toppings_list != null){
    toppingsList = toppings_list.map((i) =>
        Toppings.fromJson(i)).toList();
  }
    return new Order(
      food: new FoodRecords(
          uuid: parsedJson['uuid'],
          price: parsedJson['price'],
          name: parsedJson['name'],
          image: parsedJson['image'],
          variants: [
            new Variants(
                uuid: parsedJson['variant_uuid'],
                name: (parsedJson['variant_name'] != null) ? parsedJson['variant_name'] : ''
            )
          ],
          toppings: toppingsList
      ),
      quantity: parsedJson['number'],
      date: DateTime.now().toString(),
      restaurant: Records.fromJson(parsedJson['restaurant'])
    );
  }
}