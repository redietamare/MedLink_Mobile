class DeliveryAddress {
  final String street;
  final String city;
  final String state;
  final String zipCode;

  DeliveryAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  String toString() {
    return 'DeliveryAddress(street: $street, city: $city, state: $state, zipCode: $zipCode)';
  }
}

class EmergencyContact {
  final String? name;
  final String? phone;

  EmergencyContact({this.name, this.phone});
  @override
  String toString() {
    return 'EmergencyContact(name: $name, phone: $phone)';
  }
}

class Profile {
  final String? id;
  final String? fullName;
  final String? email;
  final String? userType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? hasCompleteProfile;
  final String? phoneNumber; // Made nullable
  final String? gender; // Made nullable
  final String? alternatePhoneNumber;
  final DateTime? dateOfBirth;
  final DeliveryAddress deliveryAddress;
  final EmergencyContact? emergencyContact;
  final List<String> healthDetails;
  final String? profilePicture;
  @override
  String toString() {
    return '''
    Profile(
      fullName: $fullName,
      email: $email,
      phoneNumber: $phoneNumber,
      gender: $gender,
      dateOfBirth: $dateOfBirth,
      deliveryAddress: $deliveryAddress,
      emergencyContact: $emergencyContact,
      healthDetails: $healthDetails,
      profilePicture: ${profilePicture != null ? '[Base64 String]' : 'None'}
    )
    ''';
  }

  Profile({
    this.id,
    this.fullName,
    this.email,
    this.userType,
    this.createdAt,
    this.updatedAt,
    this.hasCompleteProfile,
    this.phoneNumber, // Removed required
    this.gender, // Removed required
    this.alternatePhoneNumber,
    this.dateOfBirth,
    required this.deliveryAddress,
    this.emergencyContact,
    required this.healthDetails,
    this.profilePicture,
  });
}
