import 'dart:convert';

import 'package:okejek_flutter/models/auth/driver_model.dart';
import 'package:okejek_flutter/models/login/user_model.dart';

OrderChatMessages orderChatMessagesFromJson(String str) =>
    OrderChatMessages.fromJson(json.decode(str));

String orderChatMessagesToJson(OrderChatMessages data) =>
    json.encode(data.toJson());

class OrderChatMessages {
  final List<OrderChatMessage> orderChatMessages;

  OrderChatMessages({
    required this.orderChatMessages,
  });

  factory OrderChatMessages.fromJson(Map<String, dynamic> json) =>
      OrderChatMessages(
        orderChatMessages: List<OrderChatMessage>.from(
            json["order_chat_messages"]
                .map((x) => OrderChatMessage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "order_chat_messages":
            List<dynamic>.from(orderChatMessages.map((x) => x.toJson())),
      };
}

class OrderChatMessage {
  final int id;
  final Driver? driver;
  final User? user;
  final int type;
  final String content;
  final DateTime createdAt;

  OrderChatMessage({
    required this.id,
    this.driver,
    this.user,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  factory OrderChatMessage.fromJson(Map<String, dynamic> json) =>
      OrderChatMessage(
        id: json["id"],
        driver: json["driver"] != null
            ? Driver.fromJson(json["driver"])
            : null,
        user: json["user"] != null
            ? User.fromJson(json["user"])
            : null,
        type: json["type"],
        content: json["content"] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "driver": driver?.toJson(),
        "user": user?.toJson(),
        "type": type,
        "content": content,
        "created_at": createdAt.toIso8601String(),
      };
}
