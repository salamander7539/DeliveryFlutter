import 'package:faem_app/GetData/getTicketByFilter.dart';
import 'package:faem_app/data/data.dart';

class TicketModel{
  String uuid;
  String title;
  String description;

  TicketModel( {
    this.uuid,
    this.title,
    this.description
  });
}


class TicketsList {
  TicketsList({
    this.records,
    this.recordsCount,
  });

  List<TicketsListRecord> records;
  int recordsCount;

  factory TicketsList.fromJson(Map<String, dynamic> json) => TicketsList(
    records: List<TicketsListRecord>.from(json["records"].map((x) => TicketsListRecord.fromJson(x))),
    recordsCount: json["records_count"],
  );

  Map<String, dynamic> toJson() => {
    "records": List<dynamic>.from(records.map((x) => x.toJson())),
    "records_count": recordsCount,
  };

  static Future<bool> hasNewMessage() async{
    var newMessageInService = await getTicketsByFilter(1, 12, necessaryDataForAuth.phone_number, status: 'new');
    if(newMessageInService.recordsCount == 0){
      return false;
    }
    return true;
  }
}

class TicketsListRecord {
  TicketsListRecord({
    this.uuid,
    this.title,
    this.description,
    this.status,
    this.sourceType,
    this.operatorData,
    this.storeData,
    this.driverData,
    this.clientData,
    this.orderData,
    this.comments,
    this.createdAtUnix,
  });

  String uuid;
  String title;
  String description;
  String status;
  String sourceType;
  Data operatorData;
  Data storeData;
  DriverData driverData;
  ClientData clientData;
  OrderData orderData;
  List<Comment> comments;
  int createdAtUnix;

  factory TicketsListRecord.fromJson(Map<String, dynamic> json) => TicketsListRecord(
    uuid: json["uuid"],
    title: json["title"],
    description: json["description"],
    status: json["status"],
    sourceType: json["source_type"],
    operatorData: Data.fromJson(json["operator_data"]),
    storeData: Data.fromJson(json["store_data"]),
    driverData: DriverData.fromJson(json["driver_data"]),
    clientData: ClientData.fromJson(json["client_data"]),
    orderData: OrderData.fromJson(json["order_data"]),
    comments: json["comments"] == null ? null : List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
    createdAtUnix: json["created_at_unix"],
  );

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "title": title,
    "description": description,
    "status": status,
    "source_type": sourceType,
    "operator_data": operatorData.toJson(),
    "store_data": storeData.toJson(),
    "driver_data": driverData.toJson(),
    "client_data": clientData.toJson(),
    "order_data": orderData.toJson(),
    "comments": comments == null ? null : List<dynamic>.from(comments.map((x) => x.toJson())),
    "created_at_unix": createdAtUnix,
  };
}

class ClientData {
  ClientData({
    this.phone,
    this.uuid,
  });

  String phone;
  String uuid;

  factory ClientData.fromJson(Map<String, dynamic> json) => ClientData(
    phone: json["phone"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "uuid": uuid,
  };
}

class Comment {
  Comment({
    this.senderType,
    this.senderUuid,
    this.createdAtUnix,
    this.senderName,
    this.message,
  });

  String senderType;
  String senderUuid;
  int createdAtUnix;
  String senderName;
  String message;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    senderType: json["sender_type"],
    senderUuid: json["sender_uuid"],
    createdAtUnix: json["created_at_unix"],
    senderName: json["sender_name"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "sender_type": senderType,
    "sender_uuid": senderUuid,
    "created_at_unix": createdAtUnix,
    "sender_name": senderName,
    "message": message,
  };
}

class DriverData {
  DriverData({
    this.name,
    this.uuid,
    this.alias,
  });

  String name;
  String uuid;
  int alias;

  factory DriverData.fromJson(Map<String, dynamic> json) => DriverData(
    name: json["name"],
    uuid: json["uuid"],
    alias: json["alias"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "uuid": uuid,
    "alias": alias,
  };
}

class Data {
  Data({
    this.name,
    this.uuid,
  });

  String name;
  String uuid;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    name: json["name"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "uuid": uuid,
  };
}

class OrderData {
  OrderData({
    this.id,
    this.uuid,
  });

  int id;
  String uuid;

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
    id: json["id"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uuid": uuid,
  };
}
