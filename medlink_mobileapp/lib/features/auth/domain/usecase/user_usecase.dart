import 'package:dartz/dartz.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/auth/data/data_source/remote_data_source.dart';
import 'package:medlink_mobileapp/features/auth/data/repository/user_repository_impl.dart';
import 'package:medlink_mobileapp/features/auth/domain/entity/user_entity.dart';


class RegisterUserUseCase {
  final UserRepository userRepository;

  RegisterUserUseCase(this.userRepository);
  Future<Either<Failure, RegisterResponse>> register(
      String name, String email, String password, String userType) {
    return userRepository.registerUser(name, email, password, userType);
  }
}

class ResendVerificationCodeUseCase {
  final UserRepository userRepository;

  ResendVerificationCodeUseCase(this.userRepository);

  Future<Either<Failure, RegisterResponse>> resend(
      String name, String email, String password, String userType) {
    return userRepository.resendVerificationCode(
        name, email, password, userType);
  }
}

class VerifySignupUseCase {
  final UserRepository userRepository;

  VerifySignupUseCase(this.userRepository);

  Future<Either<Failure, bool>> verify(
      String email, String userType, String otpCode) {
    return userRepository.verifySignup(email, userType, otpCode);
  }
}

class LoginUseCase {
  final UserRepository userRepository;

  LoginUseCase(this.userRepository);

  Future<Either<Failure, UserEntity>> login(
      String email, String userType, String password, bool rememberMe) {
    return userRepository.login(email, userType, password, rememberMe);
  }
}

class RefreshTokenUseCase {
  final UserRepository userRepository;

  RefreshTokenUseCase(this.userRepository);

  /// Refreshes the user's access token using the refresh token.
  /// Returns [UserEntity] on success, or [Failure] on error.
  Future<Either<Failure, UserEntity>> refresh(
      String refreshToken, String userType) {
    return userRepository.refreshToken(refreshToken, userType);
  }
}

class LogoutUseCase {
  final UserRepository userRepository;

  LogoutUseCase(this.userRepository);

  Future<Either<Failure, bool>> logout(String accessToken) {
    return userRepository.logout(accessToken);
  }
}

class ForgotPasswordUseCase {
  final UserRepository userRepository;

  ForgotPasswordUseCase(this.userRepository);


  Future<Either<Failure, bool>> forgotPassword(String email, String userType) {
    return userRepository.forgotPassword(email, userType);
  }
}

class ResetPasswordUseCase {
  final UserRepository userRepository;

  ResetPasswordUseCase(this.userRepository);


  Future<Either<Failure, bool>> reset(
      String email, String userType, String password, String token) {
    return userRepository.resetPassword(email, userType, password, token);
  }
}
