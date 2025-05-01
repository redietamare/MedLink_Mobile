import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/core/network_info.dart';
import 'package:medlink_mobileapp/features/auth/data/data_source/remote_data_source.dart';
import 'package:medlink_mobileapp/features/auth/domain/entity/user_entity.dart';
import 'package:medlink_mobileapp/features/auth/domain/usecase/user_usecase.dart';


abstract class UserRepository {
  Future<Either<Failure, RegisterResponse>> registerUser(
      String name, String email, String password, String userType);
  Future<Either<Failure, RegisterResponse>> resendVerificationCode(
      String name, String email, String password, String userType);
  Future<Either<Failure, bool>> verifySignup(
      String email, String userType, String otpCode);
  Future<Either<Failure, UserEntity>> login(
      String email, String userType, String password, bool rememberMe);
  Future<Either<Failure, UserEntity>> refreshToken(
      String refreshToken, String userType);
  Future<Either<Failure, bool>> logout(String accessToken);
  Future<Either<Failure, bool>> forgotPassword(String email, String userType);
  Future<Either<Failure, bool>> resetPassword(
      String email, String userType, String password, String token);
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, RegisterResponse>> registerUser(
      String name, String email, String password, String userType) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.register(name, email, password, userType);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, RegisterResponse>> resendVerificationCode(
      String name, String email, String password, String userType) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.resendVerificationCode(name, email, password, userType);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifySignup(String email, String userType, String otpCode) async {
    if (await networkInfo.isConnected) {
      try {
        final success = await remoteDataSource.verifySignup(email, userType, otpCode);
        return Right(success);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String userType, String password, bool rememberMe) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.login(email, userType, password, rememberMe);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken(String refreshToken, String userType) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.refreshToken(refreshToken, userType);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout(String accessToken) async {
    if (await networkInfo.isConnected) {
      try {
        final success = await remoteDataSource.logout(accessToken);
        return Right(success);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> forgotPassword(String email, String userType) async {
    if (await networkInfo.isConnected) {
      try {
        final success = await remoteDataSource.forgotPassword(email, userType);
        return Right(success);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
      String email, String userType, String password, String otpCode) async {
    if (await networkInfo.isConnected) {
      try {
        final success = await remoteDataSource.resetPassword(email, userType, password, otpCode);
        return Right(success);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on SocketException catch (e) {
        return Left(ConnectionFailure('Network error: $e'));
      } catch (e) {
        return Left(UnexpectedFailure('Unexpected error: $e'));
      }
    } else {
      return Left(ConnectionFailure('No internet connection'));
    }
  }
}