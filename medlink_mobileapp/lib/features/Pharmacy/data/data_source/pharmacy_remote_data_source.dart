import 'package:medlink_mobileapp/core/constants.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/pharmacy_model.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
abstract class PharmacyRemoteDataSource {
  Future<Pharmacy> getPharmacyById(String pharmacyId, String token);
  Future<List<Pharmacy>> getAllPharmacies(String token);
  Future<List<PharmacyReview>> getPharmacyReviews(String pharmacyId, String token);
  Future<void> writePharmacyReview(String pharmacyId, int rate, String content, String token);
  Future<List<MedicineModel>> getPharmacyProducts(String pharmacyId, String token);
}

// Concrete Implementation
class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final http.Client client;

  PharmacyRemoteDataSourceImpl({required this.client});

  @override
  Future<Pharmacy> getPharmacyById(String pharmacyId, String token) async {
    final Uri url = Uri.parse('${Urls.pharmacyUrl}/detail/$pharmacyId');
    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true && json['data'] != null) {
        return Pharmacy.fromJson(json['data']);
      } else {
        throw ServerException('Failed to fetch pharmacy: Invalid response');
      }
    } else {
      throw ServerException('Failed to fetch pharmacy: ${response.statusCode}');
    }
  }

  @override
  Future<List<Pharmacy>> getAllPharmacies(String token) async {
    final url = Uri.parse(Urls.findpharmaciesUrl);
    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true && json['data'] != null) {
        return (json['data'] as List)
            .map((e) => Pharmacy.fromJson(e))
            .toList();
      } else {
        throw ServerException('Failed to fetch pharmacies: Invalid response');
      }
    } else {
      throw ServerException('Failed to fetch pharmacies: ${response.statusCode}');
    }
  }

  @override
  Future<List<PharmacyReview>> getPharmacyReviews(String pharmacyId, String token) async {
    final Uri url = Uri.parse('${Urls.pharmacyUrl}/reviews?pharmacy_id=$pharmacyId');
    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("getPharmacyReviews response");
    print(url);
    print(response.body);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true && json['data'] != null) {
        return (json['data'] as List)
            .map((e) => PharmacyReview.fromJson(e))
            .toList();
      } else {
        throw ServerException('Failed to fetch reviews: Invalid response');
      }
    } else {
      throw ServerException('Failed to fetch reviews: ${response.statusCode}');
    }
  }

  @override
  Future<void> writePharmacyReview(String pharmacyId, int rate, String content, String token) async {
    final Uri url = Uri.parse('${Urls.pharmacyUrl}/review/write');
    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pharmacy_id': pharmacyId,
        'rate': rate,
        'content': content,
      }),
    );
    print(url);
    print("writePharmacyReview response");
    print(response.body);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true) {
        return;
      } else {
        throw ServerException('Failed to write review: Invalid response');
      }
    } else {
      throw ServerException('Failed to write review: ${response.statusCode}');
    }
  }
  @override
  Future<List<MedicineModel>> getPharmacyProducts(String pharmacyId, String token) async {
    final url = Uri.parse(Urls.searchUrl);
    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pharmacy_id': pharmacyId,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true && json['data'] != null) {
        return (json['data'] as List)
            .map((e) => MedicineModel.fromJson(e))
            .toList();
      } else {
        throw ServerException('Failed to fetch pharmacy products: Invalid response');
      }
    } else {
      throw ServerException('Failed to fetch pharmacy products: ${response.statusCode}');
    }
  }
}