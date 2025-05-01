import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/profile_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/profile_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/profile_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/profile_state.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  late String email;
  late String token;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();

  String? selectedGender;
  List<String> selectedHealthDetails = [];
  File? _profileImage;
  String? _profilePictureBase64;

  final List<String> healthDetails = [
    'Diabetes',
    'Pregnancy',
    'Hypertension',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      email = args?['email'] as String? ?? 'No email provided';
      token = args?['token'] as String? ?? '';
      emailController.text = email;
      context.read<ProfileBloc>().add(LoadProfile(token));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final sizeInBytes = await file.length();
      if (sizeInBytes > 2 * 1024 * 1024) {
        // 2MB limit
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size exceeds 2MB limit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      try {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        try {
          base64Decode(base64String);
          if (!base64String.startsWith('/9j/') &&
              !base64String.startsWith('iVBORw0KGgo') &&
              !base64String.startsWith('R0lGOD')) {
            throw Exception(
                'Unsupported image format. Must be JPEG, PNG, or GIF.');
          }
        } catch (e) {
          throw Exception('Invalid image data: $e');
        }
        setState(() {
          _profileImage = file;
          _profilePictureBase64 = base64String; // Raw Base64
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2b8761),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showHealthDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> tempSelectedHealthDetails =
            List.from(selectedHealthDetails);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Select Health Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2b8761),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: healthDetails.map((healthDetail) {
                    return CheckboxListTile(
                      title: Text(healthDetail),
                      value: tempSelectedHealthDetails.contains(healthDetail),
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            if (!tempSelectedHealthDetails
                                .contains(healthDetail)) {
                              tempSelectedHealthDetails.add(healthDetail);
                            }
                          } else {
                            tempSelectedHealthDetails.remove(healthDetail);
                          }
                        });
                      },
                      activeColor: const Color(0xFF2b8761),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedHealthDetails = tempSelectedHealthDetails;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(color: const Color(0xFF2b8761)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveProfile() {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (phoneController.text.length != 10 ||
        !phoneController.text.startsWith('09')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Phone number must be 10 digits and a valid phone number.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emergencyContactController.text.isNotEmpty &&
        (emergencyContactController.text.length != 10 ||
            !emergencyContactController.text.startsWith('09'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Emergency contact number must be 10 digits and a valid phone number.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime? dateOfBirth;
    if (dobController.text.isNotEmpty) {
      try {
        dateOfBirth = DateTime.parse(dobController.text);
        var age = DateTime.now().year - dateOfBirth.year;
        if (DateTime.now().month < dateOfBirth.month ||
            (DateTime.now().month == dateOfBirth.month &&
                DateTime.now().day < dateOfBirth.day)) {
          age--;
        }
        if (age < 13) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User should be greater than 13 years old'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date of birth format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gender is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (streetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Street address is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('City is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (stateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('State is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (zipcodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zip code is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emergencyNameController.text.isNotEmpty &&
        emergencyContactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Emergency contact phone number is required if name is provided'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (emergencyContactController.text.isNotEmpty &&
        emergencyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Emergency contact name is required if phone number is provided'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (var i = 0; i < selectedHealthDetails.length; i++) {
      selectedHealthDetails[i] = selectedHealthDetails[i].toLowerCase();
    }

    final profile = ProfileModel(
      fullName:
          fullNameController.text.isNotEmpty ? fullNameController.text : null,
      email: emailController.text,
      phoneNumber: "251" + phoneController.text.substring(1),
      gender: selectedGender == "Male" ? 'M' : 'F',
      dateOfBirth: dateOfBirth,
      deliveryAddress: DeliveryAddressModel(
        street: streetController.text,
        city: cityController.text,
        state: stateController.text,
        zipCode: zipcodeController.text,
      ),
      emergencyContact: emergencyNameController.text.isNotEmpty
          ? EmergencyContactModel(
              name: emergencyNameController.text,
              phone: "251" + emergencyContactController.text.substring(1),
            )
          : null,
      healthDetails: selectedHealthDetails,
      profilePicture: _profilePictureBase64, // Raw Base64
    );

    context.read<ProfileBloc>().add(UpdateProfileEvent(token, profile));
  }

  void _populateForm(Profile profile) {
    setState(() {
      fullNameController.text = profile.fullName ?? '';
      phoneController.text =
          profile.phoneNumber != null && (profile.phoneNumber!.length > 3)
              ? "0${profile.phoneNumber?.substring(3)}"
              : "";
      emailController.text = profile.email ?? email;
      dobController.text = profile.dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(profile.dateOfBirth!)
          : '';
      selectedGender = profile.gender == "F" ? "Female" : "Male";
      streetController.text = profile.deliveryAddress.street;
      cityController.text = profile.deliveryAddress.city;
      stateController.text = profile.deliveryAddress.state;
      zipcodeController.text = profile.deliveryAddress.zipCode;
      emergencyContactController.text = profile.emergencyContact != null &&
              profile.emergencyContact!.phone != null &&
              profile.emergencyContact!.phone!.length > 3
          ? "0${profile.emergencyContact!.phone!.substring(3)}"
          : "";
      emergencyNameController.text = profile.emergencyContact?.name ?? '';
      _profilePictureBase64 = profile.profilePicture;

      if (_profilePictureBase64 != null && _profilePictureBase64!.isNotEmpty) {
        try {
          final bytes = base64Decode(_profilePictureBase64!);
          final tempFile =
              File('${Directory.systemTemp.path}/profile_image.jpg');
          tempFile.writeAsBytesSync(bytes);
          _profileImage = tempFile;
        } catch (e) {
          _profileImage = null;
        }
      } else {
        _profileImage = null;
      }
    });
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[100],
      prefixIcon: hintText == 'Full Name'
          ? const Icon(Icons.person, color: Color(0xFF2b8761))
          : hintText == '09....'
              ? const Icon(Icons.phone, color: Color(0xFF2b8761))
              : hintText == 'helen@gmail.com'
                  ? const Icon(Icons.email, color: Color(0xFF2b8761))
                  : hintText == 'Date of birth'
                      ? const Icon(Icons.calendar_today,
                          color: Color(0xFF2b8761))
                      : hintText == 'Enter Address'
                          ? const Icon(Icons.location_on,
                              color: Color(0xFF2b8761))
                          : hintText == 'Enter City'
                              ? const Icon(Icons.location_city,
                                  color: Color(0xFF2b8761))
                              : hintText == 'Enter State'
                                  ? const Icon(Icons.map,
                                      color: Color(0xFF2b8761))
                                  : hintText == 'Enter ZipCode'
                                      ? const Icon(Icons.local_post_office,
                                          color: Color(0xFF2b8761))
                                      : hintText ==
                                              'Enter emergency contact name'
                                          ? const Icon(Icons.person,
                                              color: Color(0xFF2b8761))
                                          : hintText == '09...'
                                              ? const Icon(Icons.phone,
                                                  color: Color(0xFF2b8761))
                                              : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2b8761)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2b8761)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2b8761), width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }

  BoxDecoration _buildHealthFieldDecoration() {
    return BoxDecoration(
      border: Border.all(color: const Color(0xFF2b8761)),
      borderRadius: BorderRadius.circular(8),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    dobController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();
    emergencyContactController.dispose();
    emergencyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateForm(state.profile);
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile saved successfully!'),
                backgroundColor: Color(0xFF2b8761),
              ),
            );
            context.read<ProfileBloc>().add(LoadProfile(token));
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return _buildProfileForm(context);
        },
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Center(
            child: Text(
              "Profile",
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2b8761),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                _profileImage == null
                    ? const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_profileImage!),
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: Color(0xFF2b8761),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Upload Profile Picture (2MB size limit)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Personal Information",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2b8761),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Full Name",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: fullNameController,
            decoration: _buildInputDecoration('Full Name'),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "Phone Number",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            decoration: _buildInputDecoration('09....'),
            keyboardType: TextInputType.text,
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "Email",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            decoration: _buildInputDecoration('helen@gmail.com'),
            keyboardType: TextInputType.emailAddress,
            enabled: false,
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "Date of Birth",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: dobController,
            decoration: _buildInputDecoration('Date of birth'),
            readOnly: true,
            onTap: () => _selectDate(context),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "Gender",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGender = 'Male';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedGender == 'Male'
                            ? const Color(0xFF2b8761)
                            : Colors.grey,
                        width: selectedGender == 'Male' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: selectedGender == 'Male'
                          ? const Color(0xFF2b8761)
                          : Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.male,
                          color: selectedGender == 'Male'
                              ? Colors.white
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Male',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: selectedGender == 'Male'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGender = 'Female';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedGender == 'Female'
                            ? const Color(0xFF2b8761)
                            : Colors.grey,
                        width: selectedGender == 'Female' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: selectedGender == 'Female'
                          ? const Color(0xFF2b8761)
                          : Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.female,
                          color: selectedGender == 'Female'
                              ? Colors.white
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Female',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: selectedGender == 'Female'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Select any health conditions that apply",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showHealthDetailsDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: _buildHealthFieldDecoration(),
              child: Row(
                children: [
                  const Icon(Icons.health_and_safety, color: Color(0xFF2b8761)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedHealthDetails.isEmpty
                          ? 'Health details'
                          : selectedHealthDetails.join(', '),
                      style: GoogleFonts.poppins(
                        color: selectedHealthDetails.isEmpty
                            ? Colors.grey
                            : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF2b8761)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Delivery Address",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2b8761),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Street",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: streetController,
            decoration: _buildInputDecoration('Enter Address'),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "City",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: cityController,
            decoration: _buildInputDecoration('Enter City'),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "State",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: stateController,
            decoration: _buildInputDecoration('Enter State'),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "ZipCode",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: zipcodeController,
            decoration: _buildInputDecoration('Enter ZipCode'),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 30),
          Text(
            "Emergency Contact",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2b8761),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Name",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emergencyNameController,
            decoration: _buildInputDecoration("Enter emergency contact name"),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text(
            "Phone Number",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: emergencyContactController,
            decoration: _buildInputDecoration('09...'),
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2b8761),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Save Profile',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
