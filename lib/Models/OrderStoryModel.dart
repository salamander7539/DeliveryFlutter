import 'package:faem_app/PostData/chat.dart';
import 'package:faem_app/Models/ChatHistoryModel.dart';
import 'ResponseData.dart';
import 'RestaurantDataItems.dart';

class OrdersStoryModel{
  List<OrdersStoryModelItem> ordersStoryModelItems;

  OrdersStoryModel( {
    this.ordersStoryModelItems,
  });

  factory OrdersStoryModel.fromJson(List<dynamic> parsedJson){

    var records_list = parsedJson;
    print(records_list.runtimeType);
    List<OrdersStoryModelItem> recordList = null;
    if(records_list != null){
      recordList = records_list.map((i) =>
          OrdersStoryModelItem.fromJson(i)).toList();
    }

    return OrdersStoryModel(
      ordersStoryModelItems:recordList,
    );
  }
}

class OrdersStoryModelItem{
  String uuid;
  String comment;
  List<DestinationPoints> routes;
  Tariff tariff;
  Records store;
  List<FoodRecordsStory>products;
  int created_at_unix;
  String state_title;
  bool own_delivery;
  int price;
  String state;
  Driver driver;
  bool without_delivery;

  OrdersStoryModelItem( {
    this.uuid,
    this.comment,
    this.routes,
    this.tariff,
    this.store,
    this.products,
    this.created_at_unix,
    this.price,
    this.state_title,
    this.own_delivery,
    this.state,
    this.driver,
    this.without_delivery
  });



  factory OrdersStoryModelItem.fromJson(Map<String, dynamic> parsedJson){

    var routes_list = parsedJson['routes'] as List;

    Records store = null;
    List<DestinationPoints> routesList = new List<DestinationPoints>();
    List<FoodRecordsStory> productsList = null;
    if(routes_list != null){
      routesList = routes_list.map((i) =>
          DestinationPoints.fromJson(i)).toList();
    }

    if(parsedJson['products_data'] != null){
      store  = Records.fromJson(parsedJson['products_data']['store']);
      store.destination_points = routesList;
      if(routesList.length > 1){
        routesList.removeAt(1);
      }
      var products_list = parsedJson['products_data']['products'] as List;
      if(products_list != null){
        productsList = products_list.map((i) =>
            FoodRecordsStory.fromJson(i)).toList();
      }
    }

    return OrdersStoryModelItem(
        uuid: parsedJson['uuid'],
        comment: parsedJson['comment'],
        routes: routesList,
        store: store,
        tariff: Tariff.fromJson(parsedJson["tariff"]),
        products: productsList,
        created_at_unix: parsedJson['created_at_unix'],
        price: parsedJson['tariff']['total_price'],
        state_title: parsedJson['state_title'],
        own_delivery: parsedJson['own_delivery'],
        state: parsedJson['state'],
        driver: Driver.fromJson(parsedJson['driver']),
        without_delivery: parsedJson['without_delivery']
    );
  }

  Future<bool> hasNewMessage() async{
    bool result = false;
    ChatHistoryModel chatHistory = await Chat.loadChatHistory(uuid, 'driver');
    chatHistory.chatMessageList.forEach((message) {
      if(message.to == 'client' && !message.ack){
        result = true;
        return;
      }
    });
    return result;
  }
}

class Tariff {
  Tariff({
    this.name,
    this.totalPrice,
    this.fixedPrice,
    this.productsPrice,
    this.guaranteedDriverIncome,
    this.guaranteedDriverIncomeForDelivery,
    this.supplementToGuaranteedIncome,
    this.tariffCalcType,
    this.orderTripTime,
    this.orderCompleateDist,
    this.orderStartTime,
    this.minPaymentWithTime,
    this.currency,
    this.paymentType,
    this.maxBonusPayment,
    this.bonusPayment,
    this.items,
    this.waitingBoarding,
    this.waitingPoint,
    this.timeTaximeter,
    this.waitingPrice,
    this.surge,
    this.precalculated,
  });

  String name;
  int totalPrice;
  int fixedPrice;
  int productsPrice;
  int guaranteedDriverIncome;
  int guaranteedDriverIncomeForDelivery;
  int supplementToGuaranteedIncome;
  String tariffCalcType;
  int orderTripTime;
  int orderCompleateDist;
  int orderStartTime;
  int minPaymentWithTime;
  String currency;
  String paymentType;
  int maxBonusPayment;
  int bonusPayment;
  List<Item> items;
  Map<String, int> waitingBoarding;
  Map<String, int> waitingPoint;
  Map<String, int> timeTaximeter;
  int waitingPrice;
  dynamic surge;
  String precalculated;

  factory Tariff.fromJson(Map<String, dynamic> json) => Tariff(
    name: json["name"],
    totalPrice: json["total_price"],
    fixedPrice: json["fixed_price"],
    productsPrice: json["products_price"],
    guaranteedDriverIncome: json["guaranteed_driver_income"],
    guaranteedDriverIncomeForDelivery: json["guaranteed_driver_income_for_delivery"],
    supplementToGuaranteedIncome: json["supplement_to_guaranteed_income"],
    tariffCalcType: json["tariff_calc_type"],
    orderTripTime: json["order_trip_time"],
    orderCompleateDist: json["order_compleate_dist"],
    orderStartTime: json["order_start_time"],
    minPaymentWithTime: json["min_payment_with_time"],
    currency: json["currency"],
    paymentType: json["payment_type"],
    maxBonusPayment: json["max_bonus_payment"],
    bonusPayment: json["bonus_payment"],
    items: json["items"] == null ? null : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    waitingBoarding: json["waiting_boarding"] == null ? null : Map.from(json["waiting_boarding"]).map((k, v) => MapEntry<String, int>(k, v)),
    waitingPoint: json["waiting_point"] == null ? null : Map.from(json["waiting_point"]).map((k, v) => MapEntry<String, int>(k, v)),
    timeTaximeter: json["time_taximeter"] == null ? null : Map.from(json["time_taximeter"]).map((k, v) => MapEntry<String, int>(k, v)),
    waitingPrice: json["waiting_price"],
    surge: json["surge"],
    precalculated: json["precalculated"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "total_price": totalPrice,
    "fixed_price": fixedPrice,
    "products_price": productsPrice,
    "guaranteed_driver_income": guaranteedDriverIncome,
    "guaranteed_driver_income_for_delivery": guaranteedDriverIncomeForDelivery,
    "supplement_to_guaranteed_income": supplementToGuaranteedIncome,
    "tariff_calc_type": tariffCalcType,
    "order_trip_time": orderTripTime,
    "order_compleate_dist": orderCompleateDist,
    "order_start_time": orderStartTime,
    "min_payment_with_time": minPaymentWithTime,
    "currency": currency,
    "payment_type": paymentType,
    "max_bonus_payment": maxBonusPayment,
    "bonus_payment": bonusPayment,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "waiting_boarding": Map.from(waitingBoarding).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "waiting_point": Map.from(waitingPoint).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "time_taximeter": Map.from(timeTaximeter).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "waiting_price": waitingPrice,
    "surge": surge,
    "precalculated": precalculated,
  };
}

class Item {
  Item({
    this.name,
    this.price,
  });

  String name;
  int price;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    name: json["name"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
  };
}


class FoodRecordsStory{
  String uuid;
  String weight;
  String weight_measure;
  String name;
  String comment;
  bool available;
  int price;
  String image;
  String store_uuid;
  List<Toppings>toppings;
  int number;
  Variants selectedVariant;

  FoodRecordsStory( {
    this.uuid,
    this.weight,
    this.weight_measure,
    this.name,
    this.comment,
    this.available,
    this.price,
    this.image,
    this.store_uuid,
    this.toppings,
    this.number,
    this.selectedVariant,
  });

  factory FoodRecordsStory.fromJson(Map<String, dynamic> parsedJson){

    var toppings_list = parsedJson['toppings'] as List;
    List<Toppings> toppingsList = null;
    if(toppings_list != null){
      toppingsList = toppings_list.map((i) =>
          Toppings.fromJson(i)).toList();
    }

    var variants_list = parsedJson['selected_variant'][0] as List;
    List<Variants> variantsList = null;
    if(variants_list != null){
      variantsList = variants_list.map((i) =>
          Variants.fromJson(i)).toList();
    }

    return FoodRecordsStory(
      uuid: parsedJson['uuid'],
      weight: parsedJson['weight'],
      weight_measure: parsedJson['weight_measure'],
      name: parsedJson['name'],
      comment: parsedJson['comment'],
      available: parsedJson['available'],
      price: parsedJson['price'],
      image: parsedJson['image'],
      number: parsedJson['number'],
      store_uuid: parsedJson['store_uuid'],
      toppings: toppingsList,
      selectedVariant: Variants.fromJson(parsedJson['selected_variant']),
    );
  }
}

class Driver{
  String phone;
  String color;
  String car;
  String reg_number;

  Driver( {
    this.phone,
    this.color,
    this.car,
    this.reg_number
  });

  factory Driver.fromJson(Map<String, dynamic> parsedJson){

    return Driver(
        phone: parsedJson['phone'],
        color: parsedJson['color'],
        car: parsedJson['car'],
        reg_number: parsedJson['reg_number']
    );
  }
}