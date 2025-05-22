import 'package:dartz/dartz.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/data_source/pharmacy_remote_data_source.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/pharmacy_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';

abstract class PharmacyRepository {
  Future<Either<Failure, Pharmacy>> getPharmacyById(String pharmacyId, String token);
  Future<Either<Failure, List<Pharmacy>>> getAllPharmacies(String token);
  Future<Either<Failure, List<PharmacyReview>>> getPharmacyReviews(String pharmacyId, String token);
  Future<Either<Failure, void>> writePharmacyReview(String pharmacyId, int rate, String content, String token);
  Future<Either<Failure, List<MedicineModel>>> getPharmacyProducts(String pharmacyId, String token);
}


// Concrete Implementation
class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyRemoteDataSource remoteDataSource;

  PharmacyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Pharmacy>> getPharmacyById(String pharmacyId, String token) async {
    try {
      final pharmacy = await remoteDataSource.getPharmacyById(pharmacyId, token);
      return Right(pharmacy);
    } on ServerException catch (e) {
      if (e.message.contains('401')) {
        return Left(UnauthorizedFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Pharmacy>>> getAllPharmacies(String token) async {
    try {
      final pharmacies = await remoteDataSource.getAllPharmacies(token);
      return Right(pharmacies);
    } on ServerException catch (e) {
      if (e.message.contains('401')) {
        return Left(UnauthorizedFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PharmacyReview>>> getPharmacyReviews(String pharmacyId, String token) async {
    try {
      final reviews = await remoteDataSource.getPharmacyReviews(pharmacyId, token);
      return Right(reviews);
    } on ServerException catch (e) {
      if (e.message.contains('401')) {
        return Left(UnauthorizedFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> writePharmacyReview(String pharmacyId, int rate, String content, String token) async {
    try {
      await remoteDataSource.writePharmacyReview(pharmacyId, rate, content, token);
      return const Right(null);
    } on ServerException catch (e) {
      if (e.message.contains('401')) {
        return Left(UnauthorizedFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
    @override
  Future<Either<Failure, List<MedicineModel>>> getPharmacyProducts(String pharmacyId, String token) async {
    try {
      final medicineModels = await remoteDataSource.getPharmacyProducts(pharmacyId, token);
      return Right(medicineModels);
    } on ServerException catch (e) {
      if (e.message.contains('401')) {
        return Left(UnauthorizedFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

