import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medlink_mobileapp/core/constants.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<List<MedicineModel>> getAllMedicines(String token);
  Future<List<MedicineModel>> searchMedicinesByName(String token, String name);
  Future<List<MedicineModel>> getMedicinesByCategory(String token, String category);
  Future<MedicineModel> getMedicineById(String medicineId, String token);
  Future<void> writeMedicineReview(String medicineId, String message, String token);
  Future<List<MedicineReviewModel>> getMedicineReviews(String medicineId, String token);
  Future<List<MedicineModel>> getUserRecommendations(String token);
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://medlink.yonathan.tech/api/user';

  MedicineRemoteDataSourceImpl(this.client);

  @override
  Future<List<MedicineModel>> getAllMedicines(String token) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.searchUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );
      print("getAllMedicines response");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['ok'] == true) {
          final data = jsonResponse['data'] as List<dynamic>? ?? [];
          return data.map((item) => MedicineModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Failed to get all medicines');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException('Failed to get all medicines: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Failed to get all medicines: $e');
    }
  }

  @override
  Future<List<MedicineModel>> searchMedicinesByName(String token, String name) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.searchUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name}),
      );
      print("searchMedicinesByName response");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['ok'] == true) {
          final data = jsonResponse['data'] as List<dynamic>? ?? [];
          return data.map((item) => MedicineModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Failed to search medicines by name');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException('Failed to search medicines by name: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Failed to search medicines by name: $e');
    }
  }

  @override
  Future<List<MedicineModel>> getMedicinesByCategory(String token, String category) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.searchUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'category': category}),
      );
      print("getMedicinesByCategory response");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['ok'] == true) {
          final data = jsonResponse['data'] as List<dynamic>? ?? [];
          return data.map((item) => MedicineModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Failed to get medicines by category');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException('Failed to get medicines by category: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Failed to get medicines by category: $e');
    }
  }

  @override
  Future<MedicineModel> getMedicineById(String medicineId, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/pharmacy/medicine/$medicineId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("getMedicineById response");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['ok'] == true && jsonResponse['data'] != null) {
          final data =  MedicineModel.fromJson(jsonResponse['data'] as Map<String, dynamic>);
          print("getMedicineById data");
          print(data);
          return data;
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Failed to get medicine by ID');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException('Failed to get medicine by ID: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Failed to get medicine by ID: $e');
    }
  }

  @override
  Future<void> writeMedicineReview(String medicineId, String message, String token) async {
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/pharmacy/medicine/review/write'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'medicine_id': medicineId,
          'message': message,
        }),
      );
      print("writeMedicineReview response");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['ok'] == true) {
          return;
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Failed to write medicine review');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException('Failed to write medicine review: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Failed to write medicine review: $e');
    }
  }

  @override
  Future<List<MedicineReviewModel>> getMedicineReviews(String medicineId, String token) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/pharmacy/medicine/reviews?medicine_id=$medicineId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("getMedicineReviews response");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['ok'] == true) {
          final data = jsonResponse['data'] as List<dynamic>? ?? [];
          return data.map((item) => MedicineReviewModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Failed to get medicine reviews');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException('Failed to get medicine reviews: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Failed to get medicine reviews: $e');
    }
  }

  @override
  Future<List<MedicineModel>> getUserRecommendations(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/customer/recommendations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("getUserRecommendations response");
      print(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonResponse['ok'] == true) {
          final data = jsonResponse['data'] as List<dynamic>? ?? [];
          return data.map((item) => MedicineModel.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          throw ServerException(jsonResponse['message'] ?? 'Failed to get user recommendations');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException('Failed to get user recommendations: ${response.body}');
      }
    } catch (e) {
      throw ServerException('Failed to get user recommendations: $e');
    }
  }
}