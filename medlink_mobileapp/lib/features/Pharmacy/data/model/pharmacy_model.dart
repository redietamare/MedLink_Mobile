import 'dart:convert';
import 'package:http/http.dart' as http;



// Data Models
class Address {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
    );
  }
}

class OpenHour {
  final String day;
  final String open;
  final String close;

  OpenHour({
    required this.day,
    required this.open,
    required this.close,
  });

  factory OpenHour.fromJson(Map<String, dynamic> json) {
    return OpenHour(
      day: json['day'] ?? '',
      open: json['open'] ?? '',
      close: json['close'] ?? '',
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Pharmacy {
  final String id;
  final String pharmacyName;
  final String? description;
  final String? pharmacyLogo;
  final bool isOpen;
  final String? closes;
  final List<OpenHour>? openHours;
  final bool delivery;
  final double? rating;
  final Address address;
  final String? website;
  final Location? location;
  final String? phoneNumber;
  final int? reviews;
  final double? distance;

  Pharmacy({
    required this.id,
    required this.pharmacyName,
    this.description,
    this.pharmacyLogo,
    required this.isOpen,
    this.closes,
    this.openHours,
    required this.delivery,
    this.rating,
    required this.address,
    this.website,
    this.location,
    this.phoneNumber,
    this.reviews,
    this.distance,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'] ?? '',
      pharmacyName: json['pharmacy_name'] ?? '',
      description: json['description'],
      pharmacyLogo: json['pharmacy_logo'],
      isOpen: json['isOpen'] ?? false,
      closes: json['closes'],
      openHours: json['open_hours'] != null
          ? (json['open_hours'] as List)
              .map((e) => OpenHour.fromJson(e))
              .toList()
          : null,
      delivery: json['delivery'] ?? false,
      rating: json['rating'] != null ? (json['rating'] as num?)?.toDouble() : null,
      address: Address.fromJson(json['address'] ?? {}),
      website: json['website'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      phoneNumber: json['phone_number'],
      reviews: json['reviews'] as int?,
      distance: json['distance'] != null ? (json['distance'] as num?)?.toDouble() : null,
    );
  }
}

class PharmacyReview {
  final String id;
  final String name;
  final String content;
  final int rate;
  final String date;
  final bool my;

  PharmacyReview({
    required this.id,
    required this.name,
    required this.content,
    required this.rate,
    required this.date,
    required this.my,
  });

  factory PharmacyReview.fromJson(Map<String, dynamic> json) {
    return PharmacyReview(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      content: json['content'] ?? '',
      rate: json['rate'] ?? 0,
      date: json['date'] ?? '',
      my: json['my'] ?? false,
    );
  }
}

