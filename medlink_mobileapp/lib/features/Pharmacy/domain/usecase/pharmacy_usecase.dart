import 'package:dartz/dartz.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/pharmacy_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/repository/pharmacy_repository.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';

// Helper function to map MedicineModel to Medicine entity
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

// Use Case: Get Pharmacy By ID
class GetPharmacyById {
  final PharmacyRepository repository;

  GetPharmacyById(this.repository);

  Future<Either<Failure, Pharmacy>> call({required String pharmacyId, required String token}) async {
    return await repository.getPharmacyById(pharmacyId, token);
  }
}

// Use Case: Get All Pharmacies
class GetAllPharmacies {
  final PharmacyRepository repository;

  GetAllPharmacies(this.repository);

  Future<Either<Failure, List<Pharmacy>>> call({required String token}) async {
    return await repository.getAllPharmacies(token);
  }
}

// Use Case: Get Pharmacy Reviews
class GetPharmacyReviews {
  final PharmacyRepository repository;

  GetPharmacyReviews(this.repository);

  Future<Either<Failure, List<PharmacyReview>>> call({required String pharmacyId, required String token}) async {
    return await repository.getPharmacyReviews(pharmacyId, token);
  }
}

// Use Case: Write Pharmacy Review
class WritePharmacyReviewParams {
  final String pharmacyId;
  final int rate;
  final String content;
  final String token;

  WritePharmacyReviewParams({
    required this.pharmacyId,
    required this.rate,
    required this.content,
    required this.token,
  });
}

class WritePharmacyReview {
  final PharmacyRepository repository;

  WritePharmacyReview(this.repository);

  Future<Either<Failure, void>> call(WritePharmacyReviewParams params) async {
    return await repository.writePharmacyReview(
      params.pharmacyId,
      params.rate,
      params.content,
      params.token,
    );
  }
}

// Use Case: Get Pharmacy Products
class GetPharmacyProducts {
  final PharmacyRepository repository;

  GetPharmacyProducts(this.repository);

  Future<Either<Failure, List<Medicine>>> call({required String pharmacyId, required String token}) async {
    final result = await repository.getPharmacyProducts(pharmacyId, token);
    return result.fold(
      (failure) => Left(failure),
      (medicineModels) => Right(medicineModels.map(_mapToEntity).toList()),
    );
  }
}
