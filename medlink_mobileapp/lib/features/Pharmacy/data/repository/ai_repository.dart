
import 'package:medlink_mobileapp/features/Pharmacy/data/data_source/ai_chatbot_remote_data_sourse.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/ai_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';


abstract class AiRepository {
  Future<AiResponseModel> askAi(String description, String token);
  Future<List<MedicineModel>> getMedicineByName(String name, String token);
}

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AiResponseModel> askAi(String description, String token) async {
    try {
      return await remoteDataSource.askAi(description, token);
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  @override
  Future<List<MedicineModel>> getMedicineByName(String name, String token) async {
    try {
      return await remoteDataSource.getMedicineByName(name, token);
    } catch (e) {
      throw Exception('Failed to search medicine: $e');
    }
  }
}
