import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medlink_mobileapp/features/Pharmacy/data/model/ai_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';


abstract class AiRemoteDataSource {
  Future<AiResponseModel> askAi(String description, String token);
  Future<List<MedicineModel>> getMedicineByName(String name, String token);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final http.Client client;

  AiRemoteDataSourceImpl({required this.client});

  @override
  Future<AiResponseModel> askAi(String description, String token) async {
    final response = await client.post(
      Uri.parse('https://medlink.yonathan.tech/api/user/pharmacy/medicine/ask-ai'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'description': description}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true) {
        return AiResponseModel.fromJson(json['data']);
      } else {
        throw Exception('Failed to get AI response: ${json['message']}');
      }
    } else {
      throw Exception('Failed to get AI response: ${response.statusCode}');
    }
  }

  @override
  Future<List<MedicineModel>> getMedicineByName(String name, String token) async {
    final response = await client.post(
      Uri.parse('https://medlink.yonathan.tech/api/user/pharmacy/medicine/search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['ok'] == true) {
        return (json['data'] as List)
            .map((item) => MedicineModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to search medicine: ${json['message']}');
      }
    } else {
      throw Exception('Failed to search medicine: ${response.statusCode}');
    }
  }
}