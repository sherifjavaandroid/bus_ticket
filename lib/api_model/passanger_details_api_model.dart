// To parse this JSON data, do
//
//     final passangerdetaiss = passangerdetaissFromJson(jsonString);

import 'dart:convert';

Passangerdetaiss passangerdetaissFromJson(String str) => Passangerdetaiss.fromJson(json.decode(str));

String passangerdetaissToJson(Passangerdetaiss data) => json.encode(data.toJson());

class Passangerdetaiss {
  List<BoardingArr> boardingArr;
  List<Droppoint> droppoint;
  List<Droppoint> totalPointList;
  int totalPoint;
  String responseCode;
  String result;
  String responseMsg;

  Passangerdetaiss({
    required this.boardingArr,
    required this.droppoint,
    required this.totalPointList,
    required this.totalPoint,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Passangerdetaiss.fromJson(Map<String, dynamic> json) => Passangerdetaiss(
    boardingArr: List<BoardingArr>.from(json["BoardingArr"].map((x) => BoardingArr.fromJson(x))),
    droppoint: List<Droppoint>.from(json["Droppoint"].map((x) => Droppoint.fromJson(x))),
    totalPointList: List<Droppoint>.from(json["Total_point_list"].map((x) => Droppoint.fromJson(x))),
    totalPoint: json["Total_point"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "BoardingArr": List<dynamic>.from(boardingArr.map((x) => x.toJson())),
    "Droppoint": List<dynamic>.from(droppoint.map((x) => x.toJson())),
    "Total_point_list": List<dynamic>.from(totalPointList.map((x) => x.toJson())),
    "Total_point": totalPoint,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class BoardingArr {
  String boardTitle;
  String boardAddress;
  String pointLats;
  String pointLongs;
  String boardTime;
  List<CustomerDatum> customerData;

  BoardingArr({
    required this.boardTitle,
    required this.boardAddress,
    required this.pointLats,
    required this.pointLongs,
    required this.boardTime,
    required this.customerData,
  });

  factory BoardingArr.fromJson(Map<String, dynamic> json) => BoardingArr(
    boardTitle: json["board_title"],
    boardAddress: json["board_address"],
    pointLats: json["point_lats"],
    pointLongs: json["point_longs"],
    boardTime: json["board_time"],
    customerData: List<CustomerDatum>.from(json["customer_data"].map((x) => CustomerDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "board_title": boardTitle,
    "board_address": boardAddress,
    "point_lats": pointLats,
    "point_longs": pointLongs,
    "board_time": boardTime,
    "customer_data": List<dynamic>.from(customerData.map((x) => x.toJson())),
  };
}

class CustomerDatum {
  String custName;
  String custMobile;
  List<PessengerDatum> pessengerData;

  CustomerDatum({
    required this.custName,
    required this.custMobile,
    required this.pessengerData,
  });

  factory CustomerDatum.fromJson(Map<String, dynamic> json) => CustomerDatum(
    custName: json["cust_name"],
    custMobile: json["cust_mobile"],
    pessengerData: List<PessengerDatum>.from(json["pessenger_data"].map((x) => PessengerDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cust_name": custName,
    "cust_mobile": custMobile,
    "pessenger_data": List<dynamic>.from(pessengerData.map((x) => x.toJson())),
  };
}

class PessengerDatum {
  String name;
  String age;
  String gender;
  String seatNo;
  String checkIn;
  String? cancleReason;

  PessengerDatum({
    required this.name,
    required this.age,
    required this.gender,
    required this.seatNo,
    required this.checkIn,
    this.cancleReason,
  });

  factory PessengerDatum.fromJson(Map<String, dynamic> json) => PessengerDatum(
    name: json["name"],
    age: json["age"],
    gender: json["gender"],
    seatNo: json["seat_no"],
    checkIn: json["check_in"],
    cancleReason: json["cancle_reason"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "age": age,
    "gender": gender,
    "seat_no": seatNo,
    "check_in": checkIn,
    "cancle_reason": cancleReason,
  };
}

class Droppoint {
  String dropTitle;
  String dropAddress;
  String pointLats;
  String pointLongs;
  String dropTime;
  List<CustomerDatum>? customerData;

  Droppoint({
    required this.dropTitle,
    required this.dropAddress,
    required this.pointLats,
    required this.pointLongs,
    required this.dropTime,
    this.customerData,
  });

  factory Droppoint.fromJson(Map<String, dynamic> json) => Droppoint(
    dropTitle: json["drop_title"],
    dropAddress: json["drop_address"],
    pointLats: json["point_lats"],
    pointLongs: json["point_longs"],
    dropTime: json["drop_time"],
    customerData: json["customer_data"] == null ? [] : List<CustomerDatum>.from(json["customer_data"]!.map((x) => CustomerDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "drop_title": dropTitle,
    "drop_address": dropAddress,
    "point_lats": pointLats,
    "point_longs": pointLongs,
    "drop_time": dropTime,
    "customer_data": customerData == null ? [] : List<dynamic>.from(customerData!.map((x) => x.toJson())),
  };
}
