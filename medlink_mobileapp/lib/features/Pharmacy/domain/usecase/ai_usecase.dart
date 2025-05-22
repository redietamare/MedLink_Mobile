
import 'package:medlink_mobileapp/features/Pharmacy/data/model/ai_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/repository/ai_repository.dart';


class AskAiParams {
  final String description;
  final String token;

  AskAiParams({required this.description, required this.token});
}

class GetMedicineByNameParams {
  final String name;
  final String token;

  GetMedicineByNameParams({required this.name, required this.token});
}

class AskAiUseCase {
  final AiRepository repository;

  AskAiUseCase(this.repository);

  Future<AiResponseModel> call(AskAiParams params) async {
    return await repository.askAi(params.description, params.token);
  }
}

class GetMedicineByNameUseCase {
  final AiRepository repository;

  GetMedicineByNameUseCase(this.repository);

  Future<List<MedicineModel>> call(GetMedicineByNameParams params) async {
    return await repository.getMedicineByName(params.name, params.token);
  }
}
