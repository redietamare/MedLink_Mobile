import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/reset_new_password.dart';

PageRouteBuilder _buildSwipeRoute(
    String routeName, Map<String, dynamic> arguments) {
  return PageRouteBuilder(
    settings: RouteSettings(name: routeName, arguments: arguments),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ResetNewPassword();
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

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  String? emailError;
  String? lastErrorMessage;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText, String? errorText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
    );
  }

  void _resetPassword() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailError = 'Email cannot be empty.';
      });
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        emailError = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      emailError = null;
    });

    context.read<UserBloc>().add(ForgotPasswordRequested(
          email: email,
          userType: 'customer',
        ));
  }

  @override
  Widget build(BuildContext context) {
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

          if (state is AuthPasswordResetRequested) {
            Navigator.push(
              context,
              _buildSwipeRoute('/reset-new-passwword', {
                'email': emailController.text.trim(),
                'userType': 'customer',
              }),
            );
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Password reset code sent to your email.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is AuthError) {
            setState(() {
              emailError = state.message;
            });

            if (lastErrorMessage != state.message) {
              lastErrorMessage = state.message;
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2b8761)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Forgot Password',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2b8761),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Enter your email address below and we will send you a code to reset password.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Email',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: _buildInputDecoration(
                    emailController.text.isEmpty ? 'Enter your email' : '',
                    emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 450),
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
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
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
