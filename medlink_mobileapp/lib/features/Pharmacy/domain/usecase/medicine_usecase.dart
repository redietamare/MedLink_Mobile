import 'package:dartz/dartz.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/repository/medicine_repository.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';


// Helper function to map MedicineModel to Medicine
Medicine _mapToEntity(MedicineModel model) {
  return Medicine(
    id: model.id,
    pharmacyId: model.pharmacyId,
    pharmacyName: model.pharmacyName,
    name: model.name,
    description: model.description,
    dosage: model.dosage,
    form: model.form,
    prescriptionRequired: model.prescriptionRequired,
    availability: model.availability,
    category: model.category,
    price: model.price,
    quantity: model.quantity,
    image: model.image,
    batchNumber: model.batchNumber,
    manufacturedDate: model.manufacturedDate,
    expiryDate: model.expiryDate,
    storageInstructions: model.storageInstructions,
  );
}

// Helper function to map MedicineReviewModel to MedicineReview
MedicineReview _mapReviewToEntity(MedicineReviewModel model) {
  return MedicineReview(
    id: model.id,
    name: model.name,
    message: model.message,
    date: model.date,
    my: model.my,
  );
}

// Use Case: Get All Medicines
class GetAllMedicines {
  final MedicineRepository repository;

  GetAllMedicines(this.repository);

  Future<Either<Failure, List<Medicine>>> call({required String token}) async {
    try {
      final medicineModels = await repository.getAllMedicines(token);
      final medicines = medicineModels.map((model) => _mapToEntity(model)).toList();
      return Right(medicines);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

// Use Case: Search Medicines by Name
class SearchMedicinesByName {
  final MedicineRepository repository;

  SearchMedicinesByName(this.repository);

  Future<Either<Failure, List<Medicine>>> call({required String token, required String name}) async {
    try {
      final medicineModels = await repository.searchMedicinesByName(token, name);
      final medicines = medicineModels.map((model) => _mapToEntity(model)).toList();
      return Right(medicines);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

// Use Case: Get Medicines by Category
class GetMedicinesByCategory {
  final MedicineRepository repository;

  GetMedicinesByCategory(this.repository);

  Future<Either<Failure, List<Medicine>>> call({required String token, required String category}) async {
    try {
      final medicineModels = await repository.getMedicinesByCategory(token, category);
      final medicines = medicineModels.map((model) => _mapToEntity(model)).toList();
      return Right(medicines);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

// Use Case: Get Medicine by ID
class GetMedicineById {
  final MedicineRepository repository;

  GetMedicineById(this.repository);

  Future<Either<Failure, Medicine>> call({required String medicineId, required String token}) async {
    try {
      final medicineModel = await repository.getMedicineById(medicineId, token);
      final medicine = _mapToEntity(medicineModel);
      return Right(medicine);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

// Use Case: Write Medicine Review
class WriteMedicineReviewParams {
  final String medicineId;
  final String message;
  final String token;

  WriteMedicineReviewParams({
    required this.medicineId,
    required this.message,
    required this.token,
  });
}

class WriteMedicineReview {
  final MedicineRepository repository;

  WriteMedicineReview(this.repository);

  Future<Either<Failure, void>> call(WriteMedicineReviewParams params) async {
    try {
      await repository.writeMedicineReview(params.medicineId, params.message, params.token);
      return const Right(null);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

// Use Case: Get Medicine Reviews
class GetMedicineReviews {
  final MedicineRepository repository;

  GetMedicineReviews(this.repository);

  Future<Either<Failure, List<MedicineReview>>> call({required String medicineId, required String token}) async {
    try {
      final reviewModels = await repository.getMedicineReviews(medicineId, token);
      final reviews = reviewModels.map((model) => _mapReviewToEntity(model)).toList();
      return Right(reviews);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

// Use Case: Get User Recommendations
class GetUserRecommendations {
  final MedicineRepository repository;

  GetUserRecommendations(this.repository);

  Future<Either<Failure, List<Medicine>>> call({required String token}) async {
    try {
      final medicineModels = await repository.getUserRecommendations(token);
      final medicines = medicineModels.map((model) => _mapToEntity(model)).toList();
      return Right(medicines);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}