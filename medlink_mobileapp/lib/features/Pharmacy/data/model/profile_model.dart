import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';
import 'package:intl/intl.dart';

class DeliveryAddressModel extends DeliveryAddress {
  DeliveryAddressModel({
    required String street,
    required String city,
    required String state,
    required String zipCode,
  }) : super(street: street, city: city, state: state, zipCode: zipCode);

  @override
  String toString() {
    return 'DeliveryAddressModel(\n'
        '  street: $street,\n'
        '  city: $city,\n'
        '  state: $state,\n'
        '  zipCode: $zipCode\n'
        ')';
  }

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
    }..removeWhere((key, value) => value == null || value == '');
  }
}

class EmergencyContactModel extends EmergencyContact {
  EmergencyContactModel({String? name, String? phone})
      : super(name: name, phone: phone);

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    }..removeWhere((key, value) => value == null);
  }
}

class ProfileModel extends Profile {
  ProfileModel({
    String? id,
    String? fullName,
    String? email,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasCompleteProfile,
    String? phoneNumber,
    String? gender,
    String? alternatePhoneNumber,
    DateTime? dateOfBirth,
    required DeliveryAddress deliveryAddress,
    EmergencyContact? emergencyContact,
    required List<String> healthDetails,
    String? profilePicture, // Raw Base64 string
  }) : super(
          id: id,
          fullName: fullName,
          email: email,
          userType: userType,
          createdAt: createdAt,
          updatedAt: updatedAt,
          hasCompleteProfile: hasCompleteProfile,
          phoneNumber: phoneNumber,
          gender: gender,
          alternatePhoneNumber: alternatePhoneNumber,
          dateOfBirth: dateOfBirth,
          deliveryAddress: deliveryAddress,
          emergencyContact: emergencyContact,
          healthDetails: healthDetails,
          profilePicture: profilePicture,
        );

  @override
  String toString() {
    return 'ProfileModel(\n'
        '  id: $id,\n'
        '  fullName: $fullName,\n'
        '  email: $email,\n'
        '  userType: $userType,\n'
        '  createdAt: $createdAt,\n'
        '  updatedAt: $updatedAt,\n'
        '  hasCompleteProfile: $hasCompleteProfile,\n'
        '  phoneNumber: $phoneNumber,\n'
        '  gender: $gender,\n'
        '  alternatePhoneNumber: $alternatePhoneNumber,\n'
        '  dateOfBirth: $dateOfBirth,\n'
        '  deliveryAddress: $deliveryAddress,\n'
        '  emergencyContact: $emergencyContact,\n'
        '  healthDetails: $healthDetails,\n'
        '  profilePicture: ${profilePicture != null ? 'present' : 'null'}\n'
        ')';
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final profileJson =
        json['data']?['profile'] as Map<String, dynamic>? ?? json;
    return ProfileModel(
      id: json['data']?['id'] as String?,
      fullName: json['data']?['full_name'] as String?,
      email: json['data']?['email'] as String?,
      userType: json['data']?['user_type'] as String?,
      createdAt: json['data']?['created_at'] != null
          ? DateTime.parse(json['data']['created_at'])
          : null,
      updatedAt: json['data']?['updated_at'] != null
          ? DateTime.parse(json['data']['updated_at'])
          : null,
      hasCompleteProfile: json['data']?['has_complete_profile'] as bool?,
      phoneNumber: profileJson['phone_number'] as String?,
      gender: profileJson['gender'] as String?,
      alternatePhoneNumber: profileJson['alternate_phone_number'] as String?,
      dateOfBirth: profileJson['date_of_birth'] != null
          ? DateTime.parse(profileJson['date_of_birth'])
          : null,
      deliveryAddress: profileJson['delivery_address'] != null
          ? DeliveryAddressModel.fromJson(
              profileJson['delivery_address'] as Map<String, dynamic>)
          : DeliveryAddressModel(street: '', city: '', state: '', zipCode: ''),
      emergencyContact: profileJson['emergency_contact'] != null
          ? EmergencyContactModel.fromJson(
              profileJson['emergency_contact'] as Map<String, dynamic>)
          : null,
      healthDetails:
          (profileJson['health_details'] as List<dynamic>?)?.cast<String>() ??
              [],
      profilePicture: profileJson['profile_picture'] as String?, // Raw Base64
    );
  }

  Map<String, dynamic> toJson() {
    String? imageData = profilePicture;
    if (imageData != null && imageData.isNotEmpty) {
      // Determine MIME type based on Base64 prefix
      String mimeType;
      if (imageData.startsWith('/9j/')) {
        mimeType = 'image/jpeg';
      } else if (imageData.startsWith('iVBORw0KGgo')) {
        mimeType = 'image/png';
      } else if (imageData.startsWith('R0lGOD')) {
        mimeType = 'image/gif';
      } else {
        mimeType = 'image/jpeg'; // Default to JPEG
      }
      imageData = 'data:$mimeType;base64,$imageData';
    }
    return {
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(dateOfBirth!)
          : null,
      'delivery_address': (deliveryAddress as DeliveryAddressModel).toJson(),
      'emergency_contact':
          (emergencyContact as EmergencyContactModel?)?.toJson(),
      'health_details': healthDetails,
      'image': imageData,
      'full_name': fullName,
      'email': email,
    }..removeWhere(
        (key, value) => value == null || value is String && value.isEmpty);
  }
}
