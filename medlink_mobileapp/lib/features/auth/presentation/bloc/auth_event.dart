import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String userType;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });

  @override
  List<Object?> get props => [name, email, password, userType];
}

class ResendVerificationCodeRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String userType;

  const ResendVerificationCodeRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });

  @override
  List<Object?> get props => [name, email, password, userType];
}

class VerifySignupRequested extends AuthEvent {
  final String email;
  final String userType;
  final String otpCode;

  const VerifySignupRequested({
    required this.email,
    required this.userType,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [email, userType, otpCode];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String userType;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.userType,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [email, userType, password, rememberMe];
}


class RefreshTokenRequested extends AuthEvent {
  final String refreshToken;
  final String userType;

  const RefreshTokenRequested({
    required this.refreshToken,
    required this.userType,
  });

  @override
  List<Object?> get props => [refreshToken, userType];
}

class LogoutRequested extends AuthEvent {
  final String accessToken;

  const LogoutRequested({required this.accessToken});

  @override
  List<Object?> get props => [accessToken];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  final String userType;

  const ForgotPasswordRequested({
    required this.email,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, userType];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String userType;
  final String password;
  final String otpCode;

  const ResetPasswordRequested({
    required this.email,
    required this.userType,
    required this.password,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [email, userType, password, otpCode];
}