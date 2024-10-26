class BusinessHour {
  int? foodVendorId;
  int day; 
  int openHour;
  int openMinute; 
  int closeHour;
  int closeMinute; 
  bool? isOpen; 


  BusinessHour({
    this.foodVendorId,
    required this.day,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    this.isOpen,
  });

 
  factory BusinessHour.fromJson(Map<String, dynamic> json) => BusinessHour(
        foodVendorId: json["food_vendor_id"],
        day: json["day"] ?? 0, // Bisa menggunakan nilai default
        openHour: json["open_hour"] ?? 0,
        openMinute: json["open_minute"] ?? 0,
        closeHour: json["close_hour"] ?? 0,
        closeMinute: json["close_minute"] ?? 0,
        isOpen: json["is_open"],
      );


  Map<String, dynamic> toJson() => {
        "food_vendor_id": foodVendorId,
        "day": day,
        "open_hour": openHour,
        "open_minute": openMinute,
        "close_hour": closeHour,
        "close_minute": closeMinute,
        "is_open": isOpen,
      };
}
