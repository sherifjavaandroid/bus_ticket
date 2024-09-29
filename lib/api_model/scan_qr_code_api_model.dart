// To parse this JSON data, do
//
//     final scanorcode = scanorcodeFromJson(jsonString);

import 'dart:convert';

Scanorcode scanorcodeFromJson(String str) => Scanorcode.fromJson(json.decode(str));

String scanorcodeToJson(Scanorcode data) => json.encode(data.toJson());

class Scanorcode {
  String responseCode;
  String result;
  String responseMsg;

  Scanorcode({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory Scanorcode.fromJson(Map<String, dynamic> json) => Scanorcode(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}
