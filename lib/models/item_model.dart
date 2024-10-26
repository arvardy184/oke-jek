import 'dart:convert';

Item itemFromJson(String str) => Item.fromJson(json.decode(str));

String itemToJson(Item data) => json.encode(data.toJson());

class Item {
  Item({
    required this.id,
    required this.orderId,
    required this.qty,
    required this.price,
    required this.name,
    required this.detail,
    this.createdAt,
    this.updatedAt,
    required this.itemId,
    required this.type,
    required this.itemType,
  });

  int id;
  int orderId;
  int qty;
  String price;
  String name;
  String detail;
  DateTime? createdAt;
  DateTime? updatedAt;
  int itemId;
  int type;
  String itemType;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] ?? 0,
        orderId: json["order_id"] ?? 0,
        qty: json["qty"] ?? 0,
        price: json["price"] ?? '0.0',
        name: json["name"] ?? '',
        detail: json["detail"] ?? '',
        createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
        updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
        itemId: json["item_id"] ?? 0,
        type: json["type"] ?? 0,
        itemType: json["item_type"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "qty": qty,
        "price": price,
        "name": name,
        "detail": detail,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "item_id": itemId,
        "type": type,
        "item_type": itemType,
      };
}
