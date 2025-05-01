import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/login.dart';

PageRouteBuilder _buildSwipeRoute(
    String routeName, Map<String, dynamic> arguments) {
  return PageRouteBuilder(
    settings: RouteSettings(name: routeName, arguments: arguments),
    pageBuilder: (context, animation, secondaryAnimation) {
      return LoginPage();
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

class ResetNewPassword extends StatefulWidget {
  const ResetNewPassword({super.key});

  @override
  State<ResetNewPassword> createState() => _ResetNewPassword();
}

class _ResetNewPassword extends State<ResetNewPassword> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String? passwordError;
  String? confirmPasswordError;
  String? otpError;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late String email;
  late String userType;
  bool _hasError = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null || !args.containsKey('email') || !args.containsKey('userType')) {
      setState(() {
        _hasError = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/forgot-password');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Error: Missing required navigation arguments.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      });
      return;
    }

    email = args['email'] as String;
    userType = args['userType'] as String;
  }

  InputDecoration _buildInputDecoration(String labelText, String? errorText, {Widget? suffixIcon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      hintText: labelText,
      hintStyle: GoogleFonts.poppins(color: const Color(0xFFAFBACA)),
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
      suffixIcon: suffixIcon,
    );
  }

  void _resetPassword() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final otpCode = otpController.text.trim();

    // Reset errors
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
      otpError = null;
    });

    // Validate inputs
    if (password.isEmpty) {
      setState(() {
        passwordError = 'Password cannot be empty.';
      });
      return;
    }
    if (confirmPassword.isEmpty) {
      setState(() {
        confirmPasswordError = 'Confirm password cannot be empty.';
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        confirmPasswordError = 'Passwords do not match.';
      });
      return;
    }
    if (otpCode.isEmpty) {
      setState(() {
        otpError = 'OTP code cannot be empty.';
      });
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otpCode)) {
      setState(() {
        otpError = 'OTP code must be a 6-digit number.';
      });
      return;
    }

    // Dispatch reset password event
    context.read<UserBloc>().add(ResetPasswordRequested(
      email: email,
      userType: userType,
      password: password,
      otpCode: otpCode,
    ));
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2b8761))),
      );
    }

    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2b8761)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocConsumer<UserBloc, AuthState>(
        listener: (context, state) {
          _scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
          if (state is AuthPasswordReset) {
            Navigator.pushAndRemoveUntil(
              context,
              _buildSwipeRoute('/login', {'email': email}),
              (route) => false,
            );
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Password reset successful! Please login.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is AuthError) {
            setState(() {
              otpError = state.message;
            });
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2b8761)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Create New Password',
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2b8761),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Please enter and confirm your new password.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Center(
                  child: Text(
                    "OTP code has also been sent to your email.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'New Password',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: _buildInputDecoration(
                    'Enter new Password',
                    passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF2b8761),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: !_isPasswordVisible,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm Password',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  decoration: _buildInputDecoration(
                    'Enter new Password',
                    confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF2b8761),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  obscureText: !_isConfirmPasswordVisible,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                Text(
                  'OTP Code',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: otpController,
                  decoration: _buildInputDecoration('6 digit code', otpError),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 300),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2b8761),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Reset Password',
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