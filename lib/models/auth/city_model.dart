import 'dart:convert';

City cityFromJson(String str) => City.fromJson(json.decode(str));

String cityToJson(City data) => json.encode(data.toJson());

class City {
  City({
    required this.name,
    required this.id,
    required this.configs,
    required this.originalConfig,
  });

  String name;
  int id;
  Configs configs;
  OriginalConfig originalConfig;

  factory City.fromJson(Map<String, dynamic> json) => City(
        name: json["name"] ?? '',
        id: json["id"] ?? 0,
        configs: Configs.fromJson(json["configs"] ?? {}),
        originalConfig: json["original_config"] != null
            ? OriginalConfig.fromJson(json["original_config"] ?? {})
            : OriginalConfig.fromJson(json["configs"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "configs": configs.toJson(),
        "original_config": originalConfig.toJson(),
      };
}

class Configs {
  Configs({
    required this.appFeatureCar,
    required this.appFeatureCleaning,
    required this.appFeatureMassage,
    required this.appFeatureMarket,
    required this.appFeatureTrike,
    required this.appFeatureTrikeCourier,
    required this.userMessage,
    required this.userMessageTitle,
    required this.driverMessage,
  });

  bool appFeatureCar;
  bool appFeatureCleaning;
  bool appFeatureMassage;
  bool appFeatureMarket;
  bool appFeatureTrike;
  bool appFeatureTrikeCourier;
  String userMessage;
  String userMessageTitle;
  String driverMessage;

  factory Configs.fromJson(Map<String, dynamic> json) => Configs(
        appFeatureCar: json["app_feature_car"] ?? true,
        appFeatureCleaning: json["app_feature_cleaning"] ?? true,
        appFeatureMassage: json["app_feature_massage"] ?? true,
        appFeatureMarket: json["app_feature_market"] ?? true,
        appFeatureTrike: json["app_feature_trike"] ?? true,
        appFeatureTrikeCourier: json["app_feature_trike_courier"] ?? true,
        userMessage: json["user_message"] ?? '',
        userMessageTitle: json["user_message_title"] ?? '',
        driverMessage: json["driver_message"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "app_feature_car": appFeatureCar,
        "app_feature_cleaning": appFeatureCleaning,
        "app_feature_massage": appFeatureMassage,
        "app_feature_market": appFeatureMarket,
        "app_feature_trike": appFeatureTrike,
        "app_feature_trike_courier": appFeatureTrikeCourier,
        "user_message": userMessage,
        "user_message_title": userMessageTitle,
        "driver_message": driverMessage,
      };
}

class OriginalConfig {
  OriginalConfig({
    required this.appFeatureRide,
    required this.appFeatureCourier,
    required this.appFeatureShopping,
    required this.appFeatureFood,
    required this.appFeatureMart,
    required this.appFeatureCar,
    required this.appFeatureTrike,
    required this.appFeatureTrikeCourier,
    required this.appFeatureMassage,
    required this.rideDriverCommission,
    required this.rideMinimumKm,
    required this.rideMinimumFee,
    required this.rideFee,
    required this.rideLongDistance,
    required this.rideLongDistanceFee,
    required this.courierDriverCommission,
    required this.courierMinimumKm,
    required this.courierMinimumFee,
    required this.courierFee,
    required this.courierLongDistance,
    required this.courierLongDistanceFee,
    required this.shoppingDriverCommission,
    required this.shoppingMinimumKm,
    required this.shoppingMinimumFee,
    required this.shoppingFee,
    required this.shoppingLongDistance,
    required this.shoppingLongDistanceFee,
    required this.foodDriverCommission,
    required this.foodMinimumKm,
    required this.foodMinimumFee,
    required this.foodFee,
    required this.foodLongDistance,
    required this.foodLongDistanceFee,
    required this.martDriverCommission,
    required this.martMinimumKm,
    required this.martMinimumFee,
    required this.martFee,
    required this.martLongDistance,
    required this.martLongDistanceFee,
    required this.carDriverCommission,
    required this.carMinimumKm,
    required this.carMinimumFee,
    required this.carFee,
    required this.carLongDistance,
    required this.carLongDistanceFee,
    required this.trikeDriverCommission,
    required this.trikeMinimumKm,
    required this.trikeMinimumFee,
    required this.trikeFee,
    required this.trikeLongDistance,
    required this.trikeLongDistanceFee,
    required this.trikeCourierDriverCommission,
    required this.trikeCourierMinimumKm,
    required this.trikeCourierMinimumFee,
    required this.trikeCourierFee,
    required this.trikeCourierLongDistance,
    required this.trikeCourierLongDistanceFee,
    required this.orderLifetime,
    required this.nearestDriverSearchRadius,
    required this.enableAutoSuspend,
    required this.autoSuspendDays,
    required this.cancelledOrderPenaltyFee,
    required this.maxDriverCancels,
    required this.minimumWithdrawal,
    required this.minimumConvert,
    required this.uplineReward,
    required this.maxUserCancels,
    required this.userMessageTitle,
    required this.userMessage,
    required this.usingBalanceDiscount,
    required this.usingBalanceDiscountLimit,
    required this.foodMaxFeeDiscount,
    required this.maxDistanceMotorbike,
    required this.driverMessage,
    required this.enableDriverReferral,
    required this.driverReferralCommission,
    required this.userCancelPunishmentHours,
    required this.cancelPunishmentReason,
    required this.okefoodPartnerDiscountPercentage,
    required this.okefoodPartnerDiscountMax,
    required this.prpReward,
    required this.shareAm,
    required this.shareLm,
  });

  bool appFeatureRide;
  bool appFeatureCourier;
  bool appFeatureShopping;
  bool appFeatureFood;
  bool appFeatureMart;
  bool appFeatureCar;
  bool appFeatureTrike;
  bool appFeatureTrikeCourier;
  bool appFeatureMassage;
  int rideDriverCommission;
  int rideMinimumKm;
  int rideMinimumFee;
  int rideFee;
  int rideLongDistance;
  int rideLongDistanceFee;
  int courierDriverCommission;
  int courierMinimumKm;
  int courierMinimumFee;
  int courierFee;
  int courierLongDistance;
  int courierLongDistanceFee;
  int shoppingDriverCommission;
  int shoppingMinimumKm;
  int shoppingMinimumFee;
  int shoppingFee;
  int shoppingLongDistance;
  int shoppingLongDistanceFee;
  int foodDriverCommission;
  int foodMinimumKm;
  int foodMinimumFee;
  int foodFee;
  int foodLongDistance;
  int foodLongDistanceFee;
  int martDriverCommission;
  int martMinimumKm;
  int martMinimumFee;
  int martFee;
  int martLongDistance;
  int martLongDistanceFee;
  int carDriverCommission;
  int carMinimumKm;
  int carMinimumFee;
  int carFee;
  int carLongDistance;
  int carLongDistanceFee;
  int trikeDriverCommission;
  int trikeMinimumKm;
  int trikeMinimumFee;
  int trikeFee;
  int trikeLongDistance;
  int trikeLongDistanceFee;
  int trikeCourierDriverCommission;
  int trikeCourierMinimumKm;
  int trikeCourierMinimumFee;
  int trikeCourierFee;
  int trikeCourierLongDistance;
  int trikeCourierLongDistanceFee;
  int orderLifetime;
  int nearestDriverSearchRadius;
  bool enableAutoSuspend;
  int autoSuspendDays;
  int cancelledOrderPenaltyFee;
  int maxDriverCancels;
  int minimumWithdrawal;
  int minimumConvert;
  int uplineReward;
  int maxUserCancels;
  String userMessageTitle;
  String userMessage;
  int usingBalanceDiscount;
  int usingBalanceDiscountLimit;
  int foodMaxFeeDiscount;
  int maxDistanceMotorbike;
  String driverMessage;
  bool enableDriverReferral;
  int driverReferralCommission;
  int userCancelPunishmentHours;
  String cancelPunishmentReason;
  int okefoodPartnerDiscountPercentage;
  int okefoodPartnerDiscountMax;
  int prpReward;
  int shareAm;
  int shareLm;

  factory OriginalConfig.fromJson(Map<String, dynamic> json) => OriginalConfig(
        appFeatureRide: json["app_feature_ride"] ?? true,
        appFeatureCourier: json["app_feature_courier"] ?? true,
        appFeatureShopping: json["app_feature_shopping"] ?? true,
        appFeatureFood: json["app_feature_food"] ?? true,
        appFeatureMart: json["app_feature_mart"] ?? true,
        appFeatureCar: json["app_feature_car"] ?? true,
        appFeatureTrike: json["app_feature_trike"] ?? true,
        appFeatureTrikeCourier: json["app_feature_trike_courier"] ?? true,
        appFeatureMassage: json["app_feature_massage"] ?? true,
        rideDriverCommission: json["ride_driver_commission"] ?? 0,
        rideMinimumKm: json["ride_minimum_km"] ?? 0,
        rideMinimumFee: json["ride_minimum_fee"] ?? 0,
        rideFee: json["ride_fee"] ?? 0,
        rideLongDistance: json["ride_long_distance"] ?? 0,
        rideLongDistanceFee: json["ride_long_distance_fee"] ?? 0,
        courierDriverCommission: json["courier_driver_commission"] ?? 0,
        courierMinimumKm: json["courier_minimum_km"] ?? 0,
        courierMinimumFee: json["courier_minimum_fee"] ?? 0,
        courierFee: json["courier_fee"] ?? 0,
        courierLongDistance: json["courier_long_distance"] ?? 0,
        courierLongDistanceFee: json["courier_long_distance_fee"] ?? 0,
        shoppingDriverCommission: json["shopping_driver_commission"] ?? 0,
        shoppingMinimumKm: json["shopping_minimum_km"] ?? 0,
        shoppingMinimumFee: json["shopping_minimum_fee"] ?? 0,
        shoppingFee: json["shopping_fee"] ?? 0,
        shoppingLongDistance: json["shopping_long_distance"] ?? 0,
        shoppingLongDistanceFee: json["shopping_long_distance_fee"] ?? 0,
        foodDriverCommission: json["food_driver_commission"] ?? 0,
        foodMinimumKm: json["food_minimum_km"] ?? 0,
        foodMinimumFee: json["food_minimum_fee"] ?? 0,
        foodFee: json["food_fee"] ?? 0,
        foodLongDistance: json["food_long_distance"] ?? 0,
        foodLongDistanceFee: json["food_long_distance_fee"] ?? 0,
        martDriverCommission: json["mart_driver_commission"] ?? 0,
        martMinimumKm: json["mart_minimum_km"] ?? 0,
        martMinimumFee: json["mart_minimum_fee"] ?? 0,
        martFee: json["mart_fee"] ?? 0,
        martLongDistance: json["mart_long_distance"] ?? 0,
        martLongDistanceFee: json["mart_long_distance_fee"] ?? 0,
        carDriverCommission: json["car_driver_commission"] ?? 0,
        carMinimumKm: json["car_minimum_km"] ?? 0,
        carMinimumFee: json["car_minimum_fee"] ?? 0,
        carFee: json["car_fee"] ?? 0,
        carLongDistance: json["car_long_distance"] ?? 0,
        carLongDistanceFee: json["car_long_distance_fee"] ?? 0,
        trikeDriverCommission: json["trike_driver_commission"] ?? 0,
        trikeMinimumKm: json["trike_minimum_km"] ?? 0,
        trikeMinimumFee: json["trike_minimum_fee"] ?? 0,
        trikeFee: json["trike_fee"] ?? 0,
        trikeLongDistance: json["trike_long_distance"] ?? 0,
        trikeLongDistanceFee: json["trike_long_distance_fee"] ?? 0,
        trikeCourierDriverCommission: json["trike_courier_driver_commission"] ?? 0,
        trikeCourierMinimumKm: json["trike_courier_minimum_km"] ?? 0,
        trikeCourierMinimumFee: json["trike_courier_minimum_fee"] ?? 0,
        trikeCourierFee: json["trike_courier_fee"] ?? 0,
        trikeCourierLongDistance: json["trike_courier_long_distance"] ?? 0,
        trikeCourierLongDistanceFee: json["trike_courier_long_distance_fee"] ?? 0,
        orderLifetime: json["order_lifetime"] ?? 0,
        nearestDriverSearchRadius: json["nearest_driver_search_radius"] ?? 0,
        enableAutoSuspend: json["enable_auto_suspend"] ?? true,
        autoSuspendDays: json["auto_suspend_days"] ?? 0,
        cancelledOrderPenaltyFee: json["cancelled_order_penalty_fee"] ?? 0,
        maxDriverCancels: json["max_driver_cancels"] ?? 0,
        minimumWithdrawal: json["minimum_withdrawal"] ?? 0,
        minimumConvert: json["minimum_convert"] ?? 0,
        uplineReward: json["upline_reward"] ?? 0,
        maxUserCancels: json["max_user_cancels"] ?? 0,
        userMessageTitle: json["user_message_title"] ?? '',
        userMessage: json["user_message"] ?? '',
        usingBalanceDiscount: json["using_balance_discount"] ?? 0,
        usingBalanceDiscountLimit: json["using_balance_discount_limit"] ?? 0,
        foodMaxFeeDiscount: json["food_max_fee_discount"] ?? 0,
        maxDistanceMotorbike: json["max_distance_motorbike"] ?? 0,
        driverMessage: json["driver_message"] ?? '',
        enableDriverReferral: json["enable_driver_referral"] ?? true,
        driverReferralCommission: json["driver_referral_commission"] ?? 0,
        userCancelPunishmentHours: json["user_cancel_punishment_hours"] ?? 0,
        cancelPunishmentReason: json["cancel_punishment_reason"] ?? '',
        okefoodPartnerDiscountPercentage: json["okefood_partner_discount_percentage"] ?? 0,
        okefoodPartnerDiscountMax: json["okefood_partner_discount_max"] ?? 0,
        prpReward: json["prp_reward"] ?? 0,
        shareAm: json["share_am"] ?? 0,
        shareLm: json["share_lm"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "app_feature_ride": appFeatureRide,
        "app_feature_courier": appFeatureCourier,
        "app_feature_shopping": appFeatureShopping,
        "app_feature_food": appFeatureFood,
        "app_feature_mart": appFeatureMart,
        "app_feature_car": appFeatureCar,
        "app_feature_trike": appFeatureTrike,
        "app_feature_trike_courier": appFeatureTrikeCourier,
        "app_feature_massage": appFeatureMassage,
        "ride_driver_commission": rideDriverCommission,
        "ride_minimum_km": rideMinimumKm,
        "ride_minimum_fee": rideMinimumFee,
        "ride_fee": rideFee,
        "ride_long_distance": rideLongDistance,
        "ride_long_distance_fee": rideLongDistanceFee,
        "courier_driver_commission": courierDriverCommission,
        "courier_minimum_km": courierMinimumKm,
        "courier_minimum_fee": courierMinimumFee,
        "courier_fee": courierFee,
        "courier_long_distance": courierLongDistance,
        "courier_long_distance_fee": courierLongDistanceFee,
        "shopping_driver_commission": shoppingDriverCommission,
        "shopping_minimum_km": shoppingMinimumKm,
        "shopping_minimum_fee": shoppingMinimumFee,
        "shopping_fee": shoppingFee,
        "shopping_long_distance": shoppingLongDistance,
        "shopping_long_distance_fee": shoppingLongDistanceFee,
        "food_driver_commission": foodDriverCommission,
        "food_minimum_km": foodMinimumKm,
        "food_minimum_fee": foodMinimumFee,
        "food_fee": foodFee,
        "food_long_distance": foodLongDistance,
        "food_long_distance_fee": foodLongDistanceFee,
        "mart_driver_commission": martDriverCommission,
        "mart_minimum_km": martMinimumKm,
        "mart_minimum_fee": martMinimumFee,
        "mart_fee": martFee,
        "mart_long_distance": martLongDistance,
        "mart_long_distance_fee": martLongDistanceFee,
        "car_driver_commission": carDriverCommission,
        "car_minimum_km": carMinimumKm,
        "car_minimum_fee": carMinimumFee,
        "car_fee": carFee,
        "car_long_distance": carLongDistance,
        "car_long_distance_fee": carLongDistanceFee,
        "trike_driver_commission": trikeDriverCommission,
        "trike_minimum_km": trikeMinimumKm,
        "trike_minimum_fee": trikeMinimumFee,
        "trike_fee": trikeFee,
        "trike_long_distance": trikeLongDistance,
        "trike_long_distance_fee": trikeLongDistanceFee,
        "trike_courier_driver_commission": trikeCourierDriverCommission,
        "trike_courier_minimum_km": trikeCourierMinimumKm,
        "trike_courier_minimum_fee": trikeCourierMinimumFee,
        "trike_courier_fee": trikeCourierFee,
        "trike_courier_long_distance": trikeCourierLongDistance,
        "trike_courier_long_distance_fee": trikeCourierLongDistanceFee,
        "order_lifetime": orderLifetime,
        "nearest_driver_search_radius": nearestDriverSearchRadius,
        "enable_auto_suspend": enableAutoSuspend,
        "auto_suspend_days": autoSuspendDays,
        "cancelled_order_penalty_fee": cancelledOrderPenaltyFee,
        "max_driver_cancels": maxDriverCancels,
        "minimum_withdrawal": minimumWithdrawal,
        "minimum_convert": minimumConvert,
        "upline_reward": uplineReward,
        "max_user_cancels": maxUserCancels,
        "user_message_title": userMessageTitle,
        "user_message": userMessage,
        "using_balance_discount": usingBalanceDiscount,
        "using_balance_discount_limit": usingBalanceDiscountLimit,
        "food_max_fee_discount": foodMaxFeeDiscount,
        "max_distance_motorbike": maxDistanceMotorbike,
        "driver_message": driverMessage,
        "enable_driver_referral": enableDriverReferral,
        "driver_referral_commission": driverReferralCommission,
        "user_cancel_punishment_hours": userCancelPunishmentHours,
        "cancel_punishment_reason": cancelPunishmentReason,
        "okefood_partner_discount_percentage": okefoodPartnerDiscountPercentage,
        "okefood_partner_discount_max": okefoodPartnerDiscountMax,
        "prp_reward": prpReward,
        "share_am": shareAm,
        "share_lm": shareLm,
      };
}