import 'package:medlink_mobileapp/features/auth/domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? accessToken,
    String? refreshToken,
    int? expiresAt,
  }) : super(
          name: name,
          email: email,
          password: password,
          userType: userType,
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
  
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if the response is nested under "data"
    final data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserModel(
      name: data['name']?.toString() ?? data['full_name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      password: data['password']?.toString() ?? '',
      userType: data['user_type']?.toString() ?? data['userType']?.toString() ?? '',
      accessToken: data['access_token']?.toString(),
      refreshToken: data['refresh_token']?.toString(),
      expiresAt: data['expires_at'] != null ? int.tryParse(data['expires_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'user_type': userType,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt,
    };
  }
}