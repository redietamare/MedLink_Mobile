import 'package:dartz/dartz.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/repository/profile_repository.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> call(String token) async {
    return await repository.getProfile(token);
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(String token, Profile profile) async {
    print('Usecase');
    print(profile);
    return await repository.updateProfile(token, profile);
  }
}