import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/verify_signup.dart';

PageRouteBuilder _buildSwipeRoute(
    String routeName, Map<String, dynamic> arguments) {
  return PageRouteBuilder(
    settings: RouteSettings(name: routeName, arguments: arguments),
    pageBuilder: (context, animation, secondaryAnimation) {
      return VerifySignup();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  bool isPharmacy = false; // Default to Pharmacy
  bool agreeToTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? licenseNumberError;

  String? nameErrorDisplay;
  String? emailErrorDisplay;
  String? passwordErrorDisplay;
  String? confirmPasswordErrorDisplay;
  String? licenseNumberErrorDisplay;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    }

    final trimmedValue = value.trim();

    final nameParts =
        trimmedValue.split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.length < 2) {
      return 'Please enter both first and last name.';
    }

    if (trimmedValue.length < 3) {
      return 'Name must be at least 3 characters long.';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid Email Address.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    if (!hasUppercase) {
      return 'Password must contain at least 1 uppercase letter.';
    }
    if (!hasLowercase) {
      return 'Password must contain at least 1 lowercase letter.';
    }
    if (!hasNumber) {
      return 'Password must contain at least 1 number.';
    }
    if (!hasSpecialChar) {
      return 'Password must contain at least 1 special character.';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required.';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required.';
    }
    return null;
  }

  bool get isFormValid {
    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        (isPharmacy ? licenseNumberError == null : true) &&
        agreeToTerms;
  }

  InputDecoration _buildInputDecoration(String labelText, String? errorText) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      hintText: labelText,
      labelStyle: GoogleFonts.poppins(color: const Color(0xFFAFBACA)),
      errorText: errorText,
      errorMaxLines: 2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2b8761)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : const Color(0xFF2b8761),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : const Color(0xFF2b8761),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  void _updateErrorDisplay(String field, String? newError) {
    if (newError == null) {
      setState(() {
        switch (field) {
          case 'name':
            nameErrorDisplay = null;
            break;
          case 'email':
            emailErrorDisplay = null;
            break;
          case 'password':
            passwordErrorDisplay = null;
            break;
          case 'confirmPassword':
            confirmPasswordErrorDisplay = null;
            break;
          case 'licenseNumber':
            licenseNumberErrorDisplay = null;
            break;
        }
      });
      return;
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          switch (field) {
            case 'name':
              if (nameError == newError) nameErrorDisplay = newError;
              break;
            case 'email':
              if (emailError == newError) emailErrorDisplay = newError;
              break;
            case 'password':
              if (passwordError == newError) passwordErrorDisplay = newError;
              break;
            case 'confirmPassword':
              if (confirmPasswordError == newError)
                confirmPasswordErrorDisplay = newError;
              break;
            case 'licenseNumber':
              if (licenseNumberError == newError)
                licenseNumberErrorDisplay = newError;
              break;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    nameController.addListener(() {
      setState(() {
        nameError = validateName(nameController.text);
        _updateErrorDisplay('name', nameError);
      });
    });
    emailController.addListener(() {
      setState(() {
        emailError = validateEmail(emailController.text);
        _updateErrorDisplay('email', emailError);
      });
    });
    passwordController.addListener(() {
      setState(() {
        passwordError = validatePassword(passwordController.text);
        confirmPasswordError =
            validateConfirmPassword(confirmPasswordController.text);
        _updateErrorDisplay('password', passwordError);
        _updateErrorDisplay('confirmPassword', confirmPasswordError);
      });
    });
    confirmPasswordController.addListener(() {
      setState(() {
        confirmPasswordError =
            validateConfirmPassword(confirmPasswordController.text);
        _updateErrorDisplay('confirmPassword', confirmPasswordError);
      });
    });
    licenseNumberController.addListener(() {
      setState(() {
        licenseNumberError =
            validateLicenseNumber(licenseNumberController.text);
        _updateErrorDisplay('licenseNumber', licenseNumberError);
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    licenseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2b8761)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<UserBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistered) {
            // Use custom route with swipe animation
            Navigator.push(
              context,
              _buildSwipeRoute('/verify-signup', {
                'email': state.email,
                'userType': state.userType,
                'resendAt': state.resendAt,
                'name': nameController.text.trim(),
                'password': passwordController.text.trim(),
              }),
            );
          } else if (state is AuthError) {
            String message = state.message;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xFF2b8761),
            ));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Register',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2b8761),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Row(
                //   children: [
                //     Expanded(
                //       child: GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             isPharmacy = false;
                //           });
                //         },
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(vertical: 12),
                //           decoration: BoxDecoration(
                //             color: isPharmacy
                //                 ? Colors.white
                //                 : const Color(0xFF2b8761),
                //             border: Border.all(color: const Color(0xFF2b8761)),
                //             borderRadius: const BorderRadius.only(
                //               topLeft: Radius.circular(25),
                //               bottomLeft: Radius.circular(25),
                //             ),
                //           ),
                //           child: Center(
                //             child: Text(
                //               'Customer',
                //               style: GoogleFonts.poppins(
                //                 fontSize: 16,
                //                 color: isPharmacy
                //                     ? const Color(0xFF2b8761)
                //                     : Colors.white,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             isPharmacy = true;
                //           });
                //         },
                //         child: Container(
                //           padding: const EdgeInsets.symmetric(vertical: 12),
                //           decoration: BoxDecoration(
                //             color: isPharmacy
                //                 ? const Color(0xFF2b8761)
                //                 : Colors.white,
                //             border: Border.all(color: const Color(0xFF2b8761)),
                //             borderRadius: const BorderRadius.only(
                //               topRight: Radius.circular(25),
                //               bottomRight: Radius.circular(25),
                //             ),
                //           ),
                //           child: Center(
                //             child: Text(
                //               'Pharmacy',
                //               style: GoogleFonts.poppins(
                //                 fontSize: 16,
                //                 color: isPharmacy
                //                     ? Colors.white
                //                     : const Color(0xFF2b8761),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                Text(
                  isPharmacy ? 'Pharmacy Name' : 'Full Name',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: _buildInputDecoration(
                    isPharmacy
                        ? 'Enter Your Pharmacy name'
                        : 'Enter Your Full name',
                    nameErrorDisplay,
                  ),
                ),
                const SizedBox(height: 14),
                // Email Field
                Text(
                  'Email',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration:
                      _buildInputDecoration('E-mail', emailErrorDisplay),
                ),
                const SizedBox(height: 14),
                // Password Field
                Text(
                  'Password',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration:
                      _buildInputDecoration('Password', passwordErrorDisplay)
                          .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFF82b8a2),
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Confirm Password Field
                Text(
                  'Confirm Password',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: _buildInputDecoration(
                          'Confirm Password', confirmPasswordErrorDisplay)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Color(0xFF82b8a2),
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                if (isPharmacy) ...[
                  const SizedBox(height: 14),
                  Text(
                    'License Number',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: licenseNumberController,
                    decoration: _buildInputDecoration(
                        'License Number', licenseNumberErrorDisplay),
                  ),
                ],
                const SizedBox(height: 16),
                // Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF2b8761),
                    ),
                    Expanded(
                      child: Text(
                        'By clicking on ‘Create Account’, you’re agreeing to the Medlink app Terms of Service and Privacy Policy',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 200),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFormValid
                        ? () {
                            context.read<UserBloc>().add(RegisterRequested(
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  userType:
                                      isPharmacy ? 'pharmacy' : 'customer',
                                ));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2b8761),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
