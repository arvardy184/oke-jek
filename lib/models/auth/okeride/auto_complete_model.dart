
import 'dart:convert';

import 'package:okejek_flutter/models/auth/okeride/location_model.dart';

AutoComplete autoCompleteFromJson(String str) => AutoComplete.fromJson(json.decode(str));

String autoCompleteToJson(AutoComplete data) => json.encode(data.toJson());

class AutoComplete {
  AutoComplete({
    required this.searchtext,
    required this.places,
  });

  final dynamic searchtext;
  final List<AutoCompletePlace> places;

  factory AutoComplete.fromJson(Map<String, dynamic> json) => AutoComplete(
        searchtext: json["searchtext"],
        places: List<AutoCompletePlace>.from((json["places"] as List).map((x) => AutoCompletePlace.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "searchtext": searchtext,
        "places": List<dynamic>.from(places.map((x) => x.toJson())),
      };
}

class AutoCompletePlace {
  AutoCompletePlace({
    required this.name,
    required this.address,
    required this.distance,
    required this.categories,
    required this.distanceKm,
    required this.location,
  });

  final String name;
  final String address;
  final int distance;
  final String categories;
  final double distanceKm;
  final Location location;

  factory AutoCompletePlace.fromJson(Map<String, dynamic> json) => AutoCompletePlace(
        name: json["name"] as String,
        address: json["address"] as String,
        distance: json["distance"] as int,
        categories: json["categories"] as String,
        distanceKm: (json["distance_km"] as num).toDouble(),
        location: Location.fromJson(json["location"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "distance": distance,
        "categories": categories,
        "distance_km": distanceKm,
        "location": location.toJson(),
      };
}
