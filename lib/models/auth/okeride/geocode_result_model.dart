
import 'dart:convert';
import 'package:okejek_flutter/models/auth/okeride/place_model.dart';

GeocodeResult geocodeResultFromJson(String str) => GeocodeResult.fromJson(json.decode(str));

String geocodeResultToJson(GeocodeResult data) => json.encode(data.toJson());

class GeocodeResult {
  GeocodeResult({
     this.subject,
    this.reverse,
    required this.places,
    required this.provider,
    this.debug,
  });

  final String? subject;
  final bool? reverse;
  final List<Place> places;
  final String provider;
  final Debug? debug;

   factory GeocodeResult.fromJson(Map<String, dynamic> json) => GeocodeResult(
        subject: json["subject"] ,
        reverse: json["reverse"] ,
        places: List<Place>.from((json["places"] as List).map((x) => Place.fromJson(x))),
        provider: json["provider"] as String,
        debug: json["debug"] == null ? null : Debug.fromJson(json["debug"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "subject": subject,
        "reverse": reverse,
        "places": List<dynamic>.from(places.map((x) => x.toJson())),
        "provider": provider,
        "debug": debug?.toJson(),
      };
}

class Debug {
  Debug({
    required this.url,
    required this.query,
  });

  final String url;
  final Query query;

  factory Debug.fromJson(Map<String, dynamic> json) => Debug(
        url: json["url"] as String,
      query: Query.fromJson(json["query"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "query": query.toJson(),
      };
}

class Query {
  Query({
    required this.apiKey,
    required this.country,
    required this.lang,
    required this.limit,
    required this.at,
  });

  final String apiKey;
  final String country;
  final String lang;
  final String limit;
  final String at;

  factory Query.fromJson(Map<String, dynamic> json) => Query(
        apiKey: json["apiKey"] as String,
        country: json["country"] as String,
        lang: json["lang"] as String,
        limit: json["limit"] as String,
        at: json["at"] as String,
      );

  Map<String, dynamic> toJson() => {
        "apiKey": apiKey,
        "country": country,
        "lang": lang,
        "limit": limit,
        "at": at,
      };
}
