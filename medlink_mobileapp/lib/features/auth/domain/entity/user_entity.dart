import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String name;
  final String email;
  final String password;
  final String userType;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresAt;


  UserEntity({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [name, email, password, userType, accessToken, refreshToken, expiresAt];
}