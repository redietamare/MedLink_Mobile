import 'package:dartz/dartz.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/data_source/profile_remote_data_source.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/profile_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile(String token);
  Future<Either<Failure, void>> updateProfile(String token, Profile profile);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Profile>> getProfile(String token) async {
    try {
      final profileModel = await remoteDataSource.getProfile(token);
      return Right(profileModel);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
      String token, Profile profile) async {
    try {
      final profileModel = ProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        email: profile.email,
        userType: profile.userType,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
        hasCompleteProfile: profile.hasCompleteProfile,
        phoneNumber: profile.phoneNumber,
        gender: profile.gender,
        alternatePhoneNumber: profile.alternatePhoneNumber,
        dateOfBirth: profile.dateOfBirth,
        deliveryAddress: DeliveryAddressModel(
          street: profile.deliveryAddress.street,
          city: profile.deliveryAddress.city,
          state: profile.deliveryAddress.state,
          zipCode: profile.deliveryAddress.zipCode,
        ),
        emergencyContact: profile.emergencyContact != null
            ? EmergencyContactModel(
                name: profile.emergencyContact!.name,
                phone: profile.emergencyContact!.phone,
              )
            : null,
        healthDetails: profile.healthDetails,
        profilePicture: profile.profilePicture,
      );
      await remoteDataSource.updateProfile(token, profileModel);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.errors));
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}
