class Courier {
  final int id;
  final int orderId;
  final String itemDetail;
  final String senderName;
  final String senderPhone;
  final String recipientName;
  final String recipientPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double itemAmount;
  final int weight;

  Courier({
    required this.id,
    required this.orderId,
    required this.itemDetail,
    required this.senderName,
    required this.senderPhone,
    required this.recipientName,
    required this.recipientPhone,
    required this.createdAt,
    required this.updatedAt,
    required this.itemAmount,
    required this.weight,
  });

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
        id: json["id"] ?? 0,
        orderId: json["order_id"] ?? 0,
        itemDetail: json["item_detail"] ?? "",
        senderName: json["sender_name"] ?? "",
        senderPhone: json["sender_phone"] ?? "",
        recipientName: json["recipient_name"] ?? "",
        recipientPhone: json["recipient_phone"] ?? "",
        createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),
        itemAmount: double.tryParse(json["item_amount"]?.toString() ?? "0.0") ?? 0.0,
        weight: json["weight"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "item_detail": itemDetail,
        "sender_name": senderName,
        "sender_phone": senderPhone,
        "recipient_name": recipientName,
        "recipient_phone": recipientPhone,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "item_amount": itemAmount,
        "weight": weight,
      };
}
