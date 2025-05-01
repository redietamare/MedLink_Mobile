import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/verified_page.dart';

PageRouteBuilder _buildSwipeRoute(String routeName, Map<String, dynamic> arguments) {
  return PageRouteBuilder(
    settings: RouteSettings(name: routeName, arguments: arguments),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const VerifiedPage();
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

class VerifySignup extends StatefulWidget {
  const VerifySignup({super.key});

  @override
  State<VerifySignup> createState() => _VerifySignupState();
}

class _VerifySignupState extends State<VerifySignup> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String? otpError;
  String? otpErrorDisplay;

  late String email;
  late String userType;
  late String name;
  late String password;
  late int resendAt;

  Timer? _timer;
  int _secondsRemaining = 0;
  bool _canResend = false;

  AuthState? _lastState; // Track the last state to avoid repeated SnackBars

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    email = args['email'] as String;
    userType = args['userType'] as String;
    name = args['name'] as String;
    password = args['password'] as String;
    resendAt = args['resendAt'] as int;
    _startCountdown();
  }

  void _startCountdown() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final seconds = ((resendAt - now) / 1000).ceil();
    _secondsRemaining = seconds > 0 ? seconds : 0;
    _canResend = _secondsRemaining == 0;

    if (_secondsRemaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining <= 0) {
            _canResend = true;
            timer.cancel();
          }
        });
      });
    }
  }

  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP can not be Empty.';
    }
    return null;
  }

  bool get isFormValid {
    return otpError == null;
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

  void _updateErrorDisplay(String? newError) {
    if (newError == null) {
      setState(() {
        otpErrorDisplay = null;
      });
      return;
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && otpError == newError) {
        setState(() {
          otpErrorDisplay = newError;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    otpController.addListener(() {
      setState(() {
        otpError = validateOtp(otpController.text);
        _updateErrorDisplay(otpError);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    _lastState = null; // Clear last state
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey, // Assign the key to the Scaffold
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

         
          if (_lastState == state) {
            return;
          }
          _lastState = state;

         
          _scaffoldMessengerKey.currentState?.removeCurrentSnackBar();

          if (state is AuthVerified) {
      
            Navigator.pushAndRemoveUntil(
              context,
              _buildSwipeRoute('/verified', {'email': email}),
              (route) => false,
            );
       
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Account verified successfully! Please log in.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is AuthRegistered) {
            setState(() {
              resendAt = state.resendAt;
              _timer?.cancel();
              _startCountdown();
            });
         
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Verification code resent successfully.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is AuthError) {
            // Show error SnackBar
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
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2b8761)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Verify Account',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2b8761),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  "Code has been sent to $email.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Enter the code to verify your account.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: otpController,
                  decoration:
                      _buildInputDecoration('6-digit Code', otpErrorDisplay),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    GestureDetector(
                      onTap: _canResend
                          ? () {
                              context.read<UserBloc>().add(
                                    ResendVerificationCodeRequested(
                                      name: name,
                                      email: email,
                                      password: password,
                                      userType: userType,
                                    ),
                                  );
                            }
                          : null,
                      child: Text(
                        "Resend Code",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _canResend
                              ? const Color(0xFF2b8761)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _canResend
                      ? "You can now resend the code."
                      : "Resend Code in ${_secondsRemaining}s",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 180),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFormValid
                        ? () {
                            context.read<UserBloc>().add(VerifySignupRequested(
                                  email: email,
                                  userType: userType,
                                  otpCode: otpController.text,
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
                      'Verify',
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
