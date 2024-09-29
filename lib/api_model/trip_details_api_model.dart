// To parse this JSON data, do
//
//     final tripDetails = tripDetailsFromJson(jsonString);

import 'dart:convert';

TripDetails tripDetailsFromJson(String str) => TripDetails.fromJson(json.decode(str));

String tripDetailsToJson(TripDetails data) => json.encode(data.toJson());

class TripDetails {
  TripDetailsClass tripDetails;
  String currency;
  String responseCode;
  String result;
  String responseMsg;

  TripDetails({
    required this.tripDetails,
    required this.currency,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory TripDetails.fromJson(Map<String, dynamic> json) => TripDetails(
    tripDetails: TripDetailsClass.fromJson(json["TripDetails"]),
    currency: json["currency"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "TripDetails": tripDetails.toJson(),
    "currency": currency,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class TripDetailsClass {
  String busId;
  String idPickupDrop;
  String busTitle;
  String busNo;
  DateTime pickDate;
  DateTime dropDate;
  String busImg;
  String busPicktime;
  String busDroptime;
  String boardingCity;
  String dropCity;
  String busRate;
  String differencePickDrop;
  String ticketPrice;
  String decker;
  String leftSeat;
  int bookSeat;
  String totlSeat;
  String bookLimit;
  String busAc;
  String isSleeper;

  TripDetailsClass({
    required this.busId,
    required this.idPickupDrop,
    required this.busTitle,
    required this.busNo,
    required this.pickDate,
    required this.dropDate,
    required this.busImg,
    required this.busPicktime,
    required this.busDroptime,
    required this.boardingCity,
    required this.dropCity,
    required this.busRate,
    required this.differencePickDrop,
    required this.ticketPrice,
    required this.decker,
    required this.leftSeat,
    required this.bookSeat,
    required this.totlSeat,
    required this.bookLimit,
    required this.busAc,
    required this.isSleeper,
  });

  factory TripDetailsClass.fromJson(Map<String, dynamic> json) => TripDetailsClass(
    busId: json["bus_id"],
    idPickupDrop: json["id_pickup_drop"],
    busTitle: json["bus_title"],
    busNo: json["bus_no"],
    pickDate: DateTime.parse(json["pick_date"]),
    dropDate: DateTime.parse(json["drop_date"]),
    busImg: json["bus_img"],
    busPicktime: json["bus_picktime"],
    busDroptime: json["bus_droptime"],
    boardingCity: json["boarding_city"],
    dropCity: json["drop_city"],
    busRate: json["bus_rate"],
    differencePickDrop: json["Difference_pick_drop"],
    ticketPrice: json["ticket_price"],
    decker: json["decker"],
    leftSeat: json["left_seat"],
    bookSeat: json["book_seat"],
    totlSeat: json["totl_seat"],
    bookLimit: json["book_limit"],
    busAc: json["bus_ac"],
    isSleeper: json["is_sleeper"],
  );

  Map<String, dynamic> toJson() => {
    "bus_id": busId,
    "id_pickup_drop": idPickupDrop,
    "bus_title": busTitle,
    "bus_no": busNo,
    "pick_date": "${pickDate.year.toString().padLeft(4, '0')}-${pickDate.month.toString().padLeft(2, '0')}-${pickDate.day.toString().padLeft(2, '0')}",
    "drop_date": "${dropDate.year.toString().padLeft(4, '0')}-${dropDate.month.toString().padLeft(2, '0')}-${dropDate.day.toString().padLeft(2, '0')}",
    "bus_img": busImg,
    "bus_picktime": busPicktime,
    "bus_droptime": busDroptime,
    "boarding_city": boardingCity,
    "drop_city": dropCity,
    "bus_rate": busRate,
    "Difference_pick_drop": differencePickDrop,
    "ticket_price": ticketPrice,
    "decker": decker,
    "left_seat": leftSeat,
    "book_seat": bookSeat,
    "totl_seat": totlSeat,
    "book_limit": bookLimit,
    "bus_ac": busAc,
    "is_sleeper": isSleeper,
  };
}
