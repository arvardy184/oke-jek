import 'package:okejek_flutter/models/auth/okeride/location_model.dart';

class Place {
  Place({
    required this.name,
    required this.location,
  });

  final String name;
  final Location location;

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        name: json["name"],
          location: Location.fromJson(json["location"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "location": location.toJson(),
      };
}
