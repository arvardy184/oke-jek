import 'dart:convert';

List<RentalPackage> rentalPackageFromJson(String str) =>
    List<RentalPackage>.from(json.decode(str).map((x) => RentalPackage.fromJson(x)));

String rentalPackageToJson(List<RentalPackage> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RentalPackage {
  int? id;
  int? type;
  String? name;
  int? cityId;
  String? description;
  String? image;
  int? personRequired;
  int? price;
  bool? activated;
  bool? blindMasseur;
  bool? isBusiness;
  List<Pricings>? pricings;

  RentalPackage({
    this.id,
    this.type,
    this.name,
    this.cityId,
    this.description,
    this.image,
    this.personRequired,
    this.price,
    this.activated,
    this.blindMasseur,
    this.isBusiness,
    this.pricings,
  });

  factory RentalPackage.fromJson(Map<String, dynamic> json) => RentalPackage(
        id: json['id'],
        type: json['type'],
        name: json['name'],
        cityId: json['city_id'],
        description: json['description'],
        image: json['image'] ?? "",  // Ensure image is not null
        personRequired: json['person_required'],
        price: json['price'],
        activated: json['activated'],
        blindMasseur: json['blind_masseur'],
        isBusiness: json['is_business'],
        pricings: json['pricings'] != null
            ? List<Pricings>.from(json['pricings'].map((x) => Pricings.fromJson(x)))
            : [],  // Handle null pricings with empty list
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'city_id': cityId,
        'description': description,
        'image': image ?? "",  // Ensure image is not null
        'person_required': personRequired,
        'price': price,
        'activated': activated,
        'blind_masseur': blindMasseur,
        'is_business': isBusiness,
        'pricings': pricings?.map((x) => x.toJson()).toList() ?? [],  // Safeguard null
      };
}

class Pricings {
  int? id;
  int? orderPackageId;
  String? price;
  int? duration;
  int? people;

  Pricings({
    this.id,
    this.orderPackageId,
    this.price,
    this.duration,
    this.people,
  });

  factory Pricings.fromJson(Map<String, dynamic> json) => Pricings(
        id: json['id'],
        orderPackageId: json['order_package_id'],
        price: json['price'].toString(),  // Ensure price is parsed as a string
        duration: json['duration'],
        people: json['people'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_package_id': orderPackageId,
        'price': price,
        'duration': duration,
        'people': people,
      };
}
