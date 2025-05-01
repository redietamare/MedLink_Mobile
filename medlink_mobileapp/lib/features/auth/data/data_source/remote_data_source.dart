import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medlink_mobileapp/core/constants.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/features/auth/data/model/user_model.dart';
import 'package:medlink_mobileapp/features/auth/domain/entity/user_entity.dart';

abstract class UserRemoteDataSource {
  Future<RegisterResponse> register(String name, String email, String password, String userType);
  Future<RegisterResponse> resendVerificationCode(String name, String email, String password, String userType);
  Future<bool> verifySignup(String email, String userType, String otpCode);
  Future<UserEntity> login(String email, String userType, String password, bool rememberMe);
  Future<UserEntity> refreshToken(String refreshToken, String userType);
  Future<bool> logout(String accessToken);
  Future<bool> forgotPassword(String email, String userType);
  Future<bool> resetPassword(String email, String userType, String password, String token);
}

class RegisterResponse {
  final UserEntity user;
  final int resendAt;

  RegisterResponse({required this.user, required this.resendAt});
}

class UserRemoteDataSourceImpl extends UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSourceImpl({required this.client});

 @override
  Future<RegisterResponse> register(String name, String email, String password, String userType) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': name,
          'email': email,
          'password': password,
          'user_type': userType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final user = UserModel(
          email: email,
          userType: userType,
          name: name,
          password: password,
        );
        final resendAt = json['data']['resend_at'] as int;
        return RegisterResponse(user: user, resendAt: resendAt);
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Invalid user input supplied.';
        print('Register failed with status: ${response.statusCode}, message: $message');
        throw ServerException(message);
      } else {
        print('Register failed with status: ${response.statusCode}, body: ${response.body}');
        throw ServerException('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Server error: $e');
    }
  }

  @override
  Future<RegisterResponse> resendVerificationCode(String name, String email, String password, String userType) async {
    return await register(name, email, password, userType); // Reuse the register method
  }

  @override
Future<bool> verifySignup(String email, String userType, String otpCode) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.verifyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'user_type': userType,
          'otp_code': otpCode,
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['ok'] == true;
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Invalid user input supplied.';
        throw ServerException(message);
      } else if (response.statusCode == 429) {
        final json = jsonDecode(response.body);
        throw ServerException(json['message'] ?? 'Too many trials.');
      } else if (response.statusCode == 404) {
        final json = jsonDecode(response.body);
        throw ServerException(json['message'] ?? "Verification doesn't exist, it is either expired or completed.");
      } else {
        throw ServerException('Failed to verify signup: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Server error: $e');
    }
  }

  @override
Future<UserEntity> login(String email, String userType, String password, bool rememberMe) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'user_type': userType,
          'password': password,
          'remember_me': rememberMe,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['ok'] == true) {
          return UserModel.fromJson({
            'email': email,
            'user_type': userType,
            'password': password,
            ...json['data'],
          });
        } else {
          throw ServerException('Login failed: Invalid response');
        }
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Invalid user input supplied.';
        throw ServerException(message);
      } else if (response.statusCode == 403) {
        final json = jsonDecode(response.body);
        throw ServerException(json['message'] ?? 'Incorrect email or password.');
      } else {
        throw ServerException('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Server error: $e');
    }
  }

  @override
Future<UserEntity> refreshToken(String refreshToken, String userType) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.refreshUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['ok'] == true) {
          return UserModel.fromJson({
            'email': '',
            'user_type': userType,
            'password': '',
            ...json['data'],
          });
        } else {
          throw ServerException('Refresh token failed: Invalid response');
        }
      } else if (response.statusCode == 401) {
        final json = jsonDecode(response.body);
        throw ServerException(json['message'] ?? 'Authorization required.');
      } else {
        throw ServerException('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Server error: $e');
    }
  }

  @override
Future<bool> logout(String accessToken) async {
    try {
      final response = await client.delete(
        Uri.parse(Urls.logoutUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['ok'] == true;
      } else if (response.statusCode == 401) {
        final json = jsonDecode(response.body);
        throw ServerException(json['message'] ?? 'Authorization required.');
      } else {
        throw ServerException('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Server error: $e');
    }
  }

  @override
Future<bool> forgotPassword(String email, String userType) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.forgotPasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'user_type': userType,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('ForgotPassword response: ${response.body}');
        return json['ok'] == true;
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Invalid user input supplied.';
        throw ServerException(message);
      } else if (response.statusCode == 404) {
        final json = jsonDecode(response.body);
        throw ServerException(json['message'] ?? "Account doesn't exist.");
      } else {
        throw ServerException('Failed to send reset link: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Server error: $e');
    }
  }

  @override
Future<bool> resetPassword(String email, String userType, String password, String otpCode) async {
    try {
      final response = await client.post(
        Uri.parse(Urls.resetPasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'user_type': userType,
          'password': password,
          'otp_code': otpCode,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['ok'] == true;
      } else if (response.statusCode == 400) {
        final json = jsonDecode(response.body);
        throw ServerException(json['message'] ?? 'Invalid or expired password reset link.');
      } else {
        throw ServerException('Failed to reset password: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Server error: $e');
    }
  }

}