import 'package:equatable/equatable.dart';
import 'package:medlink_mobileapp/features/auth/domain/entity/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegistered extends AuthState {
  final String email;
  final String userType;
  final int resendAt;

  const AuthRegistered({required this.email, required this.userType , required this.resendAt                } );

  @override
  List<Object?> get props => [email, userType];
}

class AuthVerified extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthPasswordResetRequested extends AuthState {}

class AuthPasswordReset extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}