import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medlink_mobileapp/core/constants.dart';
import 'package:medlink_mobileapp/core/error/exception.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/profile_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String token);
  Future<void> updateProfile(String token, ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSourceImpl(this.client);

  @override
 Future<ProfileModel> getProfile(String token) async {
  try {
    final response1 = await client.get(
      Uri.parse(Urls.customerProfileUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("response1");
    print(response1.body);

    if (response1.statusCode == 200) {
      final jsonResponse = jsonDecode(response1.body) as Map<String, dynamic>;
      if (jsonResponse['ok'] == true) {
        // Case 1: Profile is not complete (has_complete_profile = false, profile = null)
        if (jsonResponse["data"]['has_complete_profile'] == false) {
          // Return a default ProfileModel with minimal data
          return ProfileModel(
            id: jsonResponse['data']['id'] as String?,
            fullName: jsonResponse['data']['full_name'] as String?,
            email: jsonResponse['data']['email'] as String?,
            userType: jsonResponse['data']['user_type'] as String?,
            createdAt: jsonResponse['data']['created_at'] != null
                ? DateTime.parse(jsonResponse['data']['created_at'])
                : null,
            updatedAt: jsonResponse['data']['updated_at'] != null
                ? DateTime.parse(jsonResponse['data']['updated_at'])
                : null,
            hasCompleteProfile: false,
            phoneNumber: null,
            gender: null,
            alternatePhoneNumber: null,
            dateOfBirth: null,
            deliveryAddress: DeliveryAddressModel(
              street: '',
              city: '',
              state: '',
              zipCode: '',
            ),
            emergencyContact: null,
            healthDetails: [],
            profilePicture: null,
          );
        }
        // Case 2: Profile is complete (has_complete_profile = true)
        else if (jsonResponse["data"]['has_complete_profile'] == true) {
          var proImage = jsonResponse['data']['profile']['profile_picture'];
          String? profilePictureBase64;
          
          // Fetch profile picture if it exists
          if (proImage != null) {
            try {
              final response2 = await client.get(
                Uri.parse('https://medlink.yonathan.tech/api/user/image/$proImage'),
                headers: {
                  'Authorization': 'Bearer $token',
                },
              );

              if (response2.statusCode == 200) {
                final imageBytes = response2.bodyBytes;
                profilePictureBase64 = base64Encode(imageBytes);
                print('Profile picture fetched successfully');
                print(profilePictureBase64);
              } else {
                print('Failed to fetch profile image: ${response2.statusCode}');
              }
            } catch (e) {
              print('Error fetching profile picture: $e');
            }
          } else {
            print('Profile picture is null or missing');
          }

          // Prepare profile data with the fetched profile picture
          final profileJson =
              jsonResponse['data']?['profile'] as Map<String, dynamic>? ??
                  jsonResponse;
          final profileData = <String, dynamic>{
            ...jsonResponse,
            'data': <String, dynamic>{
              ...?jsonResponse['data'] as Map<String, dynamic>?,
              'profile': <String, dynamic>{
                ...profileJson,
                'profile_picture': profilePictureBase64,
              },
            },
          };
          return ProfileModel.fromJson(profileData);
        } else {
          throw ServerException('Invalid profile completion status');
        }
      } else {
        throw ServerException(
            jsonResponse['message'] ?? 'Failed to fetch profile');
      }
    } else if (response1.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException('Failed to fetch profile: ${response1.body}');
    }
  } catch (e) {
    throw ServerException('Failed to fetch profile: $e');
  }
}

  @override
  Future<void> updateProfile(String token, Profile profile) async {
    try {

      final body = (profile as ProfileModel).toJson();
      print('updaterepobody');
      print(body);
      var body1 = jsonEncode(body);
      print("body1");
      print(body1);
      final response = await http.post(
        Uri.parse(Urls.customerProfileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw ServerFailure('Failed to update profile: $e');
    }
  }
}
