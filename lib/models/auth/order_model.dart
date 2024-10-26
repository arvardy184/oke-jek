import 'dart:convert';

import 'package:okejek_flutter/models/auth/driver_model.dart';
import 'package:okejek_flutter/models/auth/payment_model.dart';
import 'package:okejek_flutter/models/login/user_model.dart';
// To parse this JSON data, do
Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  final dynamic _type;

  Order({
    required this.id,
    required this.originAddress,
    required this.originLatlng,
    required this.destinationAddress,
    required this.destinationLatlng,
    required this.originAddressDetail,
    required this.destinationAddressDetail,
    required this.status,
    required dynamic type,
    required this.route,
    required this.distance,
    required this.userId,
    required this.driverId,
    this.info,
    required this.createdAt,
    this.couponId,
    required this.discount,
    required this.driverInfo,
    required this.useUserBalance,
    this.foodVendorId,
    this.coupon,
    this.driver,
    this.score,
    this.user,
    required this.items,
    required this.payments,
    this.courier,
    this.payment,
    required this.androidVersion,
    required this.originalFee,
    required this.totalDiscount,
    required this.totalShopping,
    required this.fee,
    required this.paidBalance,
    required this.paidCash,
    required this.isVerified,
  }) : _type = type;

  final int id;
  final String originAddress;
  final String originLatlng;
  final String destinationAddress;
  final String destinationLatlng;
  final String originAddressDetail;
  final String destinationAddressDetail;
  final int status;
  final String route;
  final int distance;
  final int userId;
  final int driverId;
  final String? info;
  final DateTime createdAt;
  final int? couponId;
  final int discount;
  final String driverInfo;
  final bool useUserBalance;
  final int? foodVendorId;
  final dynamic coupon;
  final Driver? driver;
  final dynamic score;
  final User? user;
  final List<dynamic> items;
  final List<dynamic> payments;
  final dynamic courier;
  final Payment? payment;
  final int androidVersion;
  final double originalFee;
  final int totalDiscount;
  final String totalShopping;
  final String fee;
  final String paidBalance;
  final String paidCash;
  final bool isVerified;

  int get typeAsInt => _type is int ? _type : int.tryParse(_type.toString()) ?? -1;

  String get typeAsString => _type.toString();

  // Helper for List Parsing
  static List<dynamic> _parseList(List<dynamic>? jsonList) =>
      jsonList != null ? List<dynamic>.from(jsonList.map((x) => x)) : [];

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"] ?? 0,
        originAddress: json["origin_address"] ?? "",
        originLatlng: json["origin_latlng"] ?? "",
        destinationAddress: json["destination_address"] ?? "",
        destinationLatlng: json["destination_latlng"] ?? "",
        originAddressDetail: json["origin_address_detail"] ?? "",
        destinationAddressDetail: json["destination_address_detail"] ?? "",
        status: json["status"] ?? 0,
        type: json["type"],
        route: json["route"] ?? "",
        distance: json["distance"] ?? 0,
        userId: json["user_id"] ?? 0,
        driverId: json["driver_id"] ?? 0,
        info: json["info"],
        createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
        couponId: json["coupon_id"],
        discount: json["discount"] ?? 0,
        driverInfo: json["driver_info"] ?? "",
        useUserBalance: json["use_user_balance"] ?? false,
        foodVendorId: json["food_vendor_id"] ?? 0,
        coupon: json["coupon"],
        driver: json["driver"] != null ? Driver.fromJson(json["driver"]) : null,
        score: json["score"] ?? 0,
        user: json["user"] != null ? User.fromJson(json["user"]) : null,
        items: _parseList(json["items"]),
        payments: _parseList(json["payments"]),
        courier: json["courier"] ?? "",
        payment: json["payment"] != null ? Payment.fromJson(json["payment"]) : null,
        androidVersion: json["android_version"] ?? 0,
        originalFee: double.tryParse(json["original_fee"]?.toString() ?? "0.0") ?? 0.0,
        totalDiscount: json["total_discount"] ?? 0,
        totalShopping: json["total_shopping"]?.toString() ?? "0",
        fee: json["fee"]?.toString() ?? "0",
        paidBalance: json["paid_balance"]?.toString() ?? "0",
        paidCash: json["paid_cash"]?.toString() ?? "0",
        isVerified: json["is_verified"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "origin_address": originAddress,
        "origin_latlng": originLatlng,
        "destination_address": destinationAddress,
        "destination_latlng": destinationLatlng,
        "origin_address_detail": originAddressDetail,
        "destination_address_detail": destinationAddressDetail,
        "status": status,
        "type": typeAsInt, // Storing as integer type
        "route": route,
        "distance": distance,
        "user_id": userId,
        "driver_id": driverId,
        "info": info,
        "created_at": createdAt.toIso8601String(),
        "coupon_id": couponId,
        "discount": discount,
        "driver_info": driverInfo,
        "use_user_balance": useUserBalance,
        "food_vendor_id": foodVendorId,
        "coupon": coupon,
        "driver": driver?.toJson(),
        "score": score,
        "user": user?.toJson(),
        "items": items,
        "payments": payments,
        "courier": courier,
        "payment": payment?.toJson(),
        "android_version": androidVersion,
        "original_fee": originalFee,
        "total_discount": totalDiscount,
        "total_shopping": totalShopping,
        "fee": fee,
        "paid_balance": paidBalance,
        "paid_cash": paidCash,
        "is_verified": isVerified,
      };
}
