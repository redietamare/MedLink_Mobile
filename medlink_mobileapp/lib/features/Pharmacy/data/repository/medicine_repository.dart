import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/data_source/medicine_remote_data_source.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';


abstract class MedicineRepository {
  Future<List<MedicineModel>> getAllMedicines(String token);
  Future<List<MedicineModel>> searchMedicinesByName(String token, String name);
  Future<List<MedicineModel>> getMedicinesByCategory(String token, String category);
  Future<MedicineModel> getMedicineById(String medicineId, String token);
  Future<void> writeMedicineReview(String medicineId, String message, String token);
  Future<List<MedicineReviewModel>> getMedicineReviews(String medicineId, String token);
  Future<List<MedicineModel>> getUserRecommendations(String token);
}

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remoteDataSource;

  MedicineRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MedicineModel>> getAllMedicines(String token) async {
    try {
      return await remoteDataSource.getAllMedicines(token);
    } catch (e) {
      throw ServerException('Repository error: $e');
    }
  }

  @override
  Future<List<MedicineModel>> searchMedicinesByName(String token, String name) async {
    try {
      return await remoteDataSource.searchMedicinesByName(token, name);
    } catch (e) {
      throw ServerException('Repository error: $e');
    }
  }

  @override
  Future<List<MedicineModel>> getMedicinesByCategory(String token, String category) async {
    try {
      return await remoteDataSource.getMedicinesByCategory(token, category);
    } catch (e) {
      throw ServerException('Repository error: $e');
    }
  }

  @override
  Future<MedicineModel> getMedicineById(String medicineId, String token) async {
    try {
      return await remoteDataSource.getMedicineById(medicineId, token);
    } catch (e) {
      throw ServerException('Repository error: $e');
    }
  }

  @override
  Future<void> writeMedicineReview(String medicineId, String message, String token) async {
    try {
      return await remoteDataSource.writeMedicineReview(medicineId, message, token);
    } catch (e) {
      throw ServerException('Repository error: $e');
    }
  }

  @override
  Future<List<MedicineReviewModel>> getMedicineReviews(String medicineId, String token) async {
    try {
      return await remoteDataSource.getMedicineReviews(medicineId, token);
    } catch (e) {
      throw ServerException('Repository error: $e');
    }
  }

  @override
  Future<List<MedicineModel>> getUserRecommendations(String token) async {
    try {
      return await remoteDataSource.getUserRecommendations(token);
    } catch (e) {
      throw ServerException('Repository error: $e');
    }
  }
}