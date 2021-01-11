import 'package:faem_app/Models/InitialAddressModel.dart';
import 'package:faem_app/Models/RecommendationAddressModel.dart';
import 'package:faem_app/Models/ResponseData.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../data/data.dart';
import 'CreateOrderModel.dart';

class MyFavouriteAddressesModel{
  // Список возможных тегов
  // null = empty
  static const List<String> MyAddressesTags = ["work","house","study", null];

  String uuid;
  FavouriteAddress address;
  String name;
  String description;
  String tag;
  String clientUuid;

  MyFavouriteAddressesModel( {
    this.address,
    this.name,
    this.description,
    this.uuid,
    this.tag,
    this.clientUuid
  });

  Future<MyFavouriteAddressesModel> ifNoBrainsSave() async{
    if(name == "")
      name = " ";
    if(uuid == null || uuid == "")
      return await save();
    else
      return await update();
  }

  Future<MyFavouriteAddressesModel> save() async{
    // Обновляем токен
    await CreateOrder.sendRefreshToken();
    // Отправляем данные на сервер
    MyFavouriteAddressesModel result;
    var jsonRequest = convert.jsonEncode(this.toServerSaveJson());
    var url = 'https://client.apis.stage.faem.pro/api/v2/addresses/favorite';
    var response = await http.post(url, body: jsonRequest, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print(response.body);
      result = MyFavouriteAddressesModel.fromJson(jsonResponse);
    } else {
      print(response.body);
      print('Request failed with status: ${response.statusCode}.');
    }
    return result;
  }

  Future<MyFavouriteAddressesModel> update() async{
    // Обновляем токен
    await CreateOrder.sendRefreshToken();
    // Отправляем данные на сервер
    MyFavouriteAddressesModel result;
    var jsonRequest = convert.jsonEncode(this.toServerSaveJson());
    var url = 'https://client.apis.stage.faem.pro/api/v2/addresses/favorite/$uuid';
    var response = await http.put(url, body: jsonRequest, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      result = MyFavouriteAddressesModel.fromJson(jsonResponse);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return result;
  }

  Future<void> delete() async{
    // Обновляем токен
    await CreateOrder.sendRefreshToken();
    // Отправляем данные на сервер
    var url = 'https://client.apis.stage.faem.pro/api/v2/addresses/favorite/$uuid';
    var response = await http.delete(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      'Authorization':'Bearer ' + authCodeData.token
    });
    if (response.statusCode == 200) {
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  static Future<List<MyFavouriteAddressesModel>> getAddresses() async{
    List<MyFavouriteAddressesModel> addressesList = List<MyFavouriteAddressesModel>();
    // Обновляем токен
    await CreateOrder.sendRefreshToken();
    // Получаем данные с сервера
    var url = 'https://client.apis.stage.faem.pro/api/v2/addresses/favorite';
    var response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Source':'ios_client_app_1',
      'Authorization':'Bearer ' + authCodeData.token
    });
    var jsonResponse;
    if (response.statusCode == 200) {
      jsonResponse = convert.jsonDecode(response.body) as List;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    addressesList = new List<MyFavouriteAddressesModel>();
    // Если что-то пошло не так, возвращаем пустой список
    if(jsonResponse == null)
      return addressesList;
    // Иначе возвращаем заполненный
    addressesList = jsonResponse.map<MyFavouriteAddressesModel>((i) =>
        MyFavouriteAddressesModel.fromJson(i)).toList();
    return addressesList;
  }

  Map<String, dynamic> toServerSaveJson() => {
    "name": name,
    "description": description,
    "tag": tag,
    "address": address.toJson(),
  };

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "name": name,
    "description": description,
    "tag": tag,
    "client_uuid": clientUuid,
    "address": address.toJson(),
  };

  factory MyFavouriteAddressesModel.fromJson(Map<String, dynamic> parsedJson){
    return new MyFavouriteAddressesModel(
      address:FavouriteAddress.fromJson(parsedJson['address']),
      uuid: parsedJson["uuid"],
      name: parsedJson["name"],
      description: parsedJson["description"],
      tag: parsedJson["tag"],
      clientUuid: parsedJson["client_uuid"],
    );
  }
}

class FavouriteAddress extends InitialAddressModel {
  // Поля класса
  String type;
  int frontDoor;

  FavouriteAddress({
    String unrestrictedValue,
    String value,
    String country,
    String region,
    String regionType,
    this.type,
    String city,
    String cityType,
    String street,
    String streetType,
    String streetWithType,
    String house,
    this.frontDoor,
    bool outOfTown,
    String houseType,
    int accuracyLevel,
    int radius,
    double lat,
    double lon,
  }):super( // Передаем данные в родительский конструктор
      unrestrictedValue: unrestrictedValue,
      value: value,
      country: country,
      region: region,
      regionType: regionType,
      city: city,
      cityType: cityType,
      street: street,
      streetType: streetType,
      streetWithType: streetWithType,
      house: house,
      outOfTown: outOfTown,
      houseType: houseType,
      accuracyLevel: accuracyLevel,
      radius: radius,
      lat: lat,
      lon: lon,
      comment: ""
  );

  factory FavouriteAddress.fromJson(Map<String, dynamic> json) => FavouriteAddress(
    unrestrictedValue: json["unrestricted_value"],
    value: json["value"],
    country: json["country"],
    region: json["region"],
    regionType: json["region_type"],
    type: json["type"],
    city: json["city"],
    cityType: json["city_type"],
    street: json["street"],
    streetType: json["street_type"],
    streetWithType: json["street_with_type"],
    house: json["house"],
    frontDoor: json["front_door"],
    outOfTown: json["out_of_town"],
    houseType: json["house_type"],
    accuracyLevel: json["accuracy_level"],
    radius: json["radius"],
    lat: json["lat"].toDouble(),
    lon: json["lon"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "unrestricted_value": unrestrictedValue,
    "value": value,
    "country": country,
    "region": region,
    "region_type": regionType,
    "type": type,
    "city": city,
    "city_type": cityType,
    "street": street,
    "street_type": streetType,
    "street_with_type": streetWithType,
    "house": house,
    "front_door": frontDoor,
    "out_of_town": outOfTown,
    "house_type": houseType,
    "accuracy_level": accuracyLevel,
    "radius": radius,
    "lat": lat,
    "lon": lon,
  };
  factory FavouriteAddress.fromInitialAddressModelChild(var address){
    // Из InitialAddressModel наследуются только DestinationPoints и FavouriteAddress
    // (InitialAddressModel нигде не используется в чистом виде)

    // Таким образом,
    // Если мы имеем дело с DestinationPoints, то на ее основе строим FavouriteAddress
    if (address is DestinationPoints) {
      return FavouriteAddress(
          unrestrictedValue: address.unrestrictedValue,
          value: address.value,
          country: address.country,
          region: address.region,
          regionType: address.regionType,
          type: address.type,
          city: address.city,
          cityType: address.cityType,
          street: address.street,
          streetType: address.streetType,
          streetWithType: address.streetWithType,
          house: address.house,
          frontDoor: address.front_door,
          outOfTown: address.outOfTown,
          houseType: address.house_type,
          accuracyLevel: address.accuracy_level,
          radius: address.radius,
          lat: address.lat,
          lon: address.lon
      );
    }
    // Иначе нам прислали FavouriteAddress
    return address;
  }
}