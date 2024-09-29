// To parse this JSON data, do
//
//     final triphistory = triphistoryFromJson(jsonString);

import 'dart:convert';

Triphistory triphistoryFromJson(String str) => Triphistory.fromJson(json.decode(str));

String triphistoryToJson(Triphistory data) => json.encode(data.toJson());

class Triphistory {
  List<TripHistory> tripHistory;
  String responseCode;
  String result;
  String responseMsg;

  Triphistory({
    required this.tripHistory,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Triphistory.fromJson(Map<String, dynamic> json) => Triphistory(
    tripHistory: List<TripHistory>.from(json["TripHistory"].map((x) => TripHistory.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "TripHistory": List<dynamic>.from(tripHistory.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class TripHistory {
  String busId;
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

  TripHistory({
    required this.busId,
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

  factory TripHistory.fromJson(Map<String, dynamic> json) => TripHistory(
    busId: json["bus_id"],
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
