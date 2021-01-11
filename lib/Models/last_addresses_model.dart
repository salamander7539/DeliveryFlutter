import 'package:faem_app/Models/ResponseData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

class LastAddressesModel{
  static List<DestinationPoints> _AddressesList;

  static Future saveData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_addresses', LastAddressesModel.toJson());
  }

  static Future<void> addAddress(DestinationPoints dp) async{
    // Получаем последние адреса при необходимости
    if(_AddressesList == null)
      await getAddresses();
    // Удаляем адрес, если он уже есть в листе
    _AddressesList.removeWhere((element) => element.uuid == dp.uuid);
    // и добавляем его в начало
    _AddressesList.insert(0, dp);

    // Если адресов больше трех, то удаляем последние
    for(int i = _AddressesList.length-1; i>2; i--){
      _AddressesList.removeAt(i);
    }

    // Сохраняем
    await saveData();
  }

  static Future<List<DestinationPoints>> getAddresses() async{
    if(_AddressesList != null)
      return _AddressesList;

    _AddressesList = new List<DestinationPoints>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('last_addresses'))
      return _AddressesList;
    var json_addresses = convert.jsonDecode(prefs.getString('last_addresses')) as List;

    _AddressesList = json_addresses.map((i) =>
        DestinationPoints.fromJson(i)).toList();
    return _AddressesList;
  }

  static Future<void> clear() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('last_addresses');
  }

  static String toJson(){
    List<Map<String, dynamic>> list = new List<Map<String, dynamic>>();
    _AddressesList.forEach((DestinationPoints address) {
      list.add(address.toJson());
    });
    return convert.jsonEncode(list);
  }
}