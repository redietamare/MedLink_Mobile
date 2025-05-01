import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? passwordError;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('email')) {
      emailController.text = args['email'] as String;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hintText, {String? errorText}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      hintText: hintText,
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
      suffixIcon: hintText.toLowerCase() == 'enter your password'
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF2b8761),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
    );
  }

  void _login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        passwordError = email.isEmpty
            ? 'Email cannot be empty.'
            : 'Password cannot be empty.';
      });
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        passwordError = 'Please enter a valid email address.';
      });
      return;
    }

    context.read<UserBloc>().add(LoginRequested(
          email: email,
          userType: 'customer', // Since this is for a customer
          password: password,
          rememberMe: false,
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
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-page',
              (route) => false,
              arguments: {'email': emailController.text.trim()},
            );
            _scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                  content: Text('Login successful!'),
                  duration: Duration(seconds: 3)),
            );
          } else if (state is AuthError) {
            setState(() {
              passwordError = state.message;
            });
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
                const SizedBox(height: 30),
                Text(
                  'Login',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2b8761),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Email',
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
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Text(
                  'Password',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: _buildInputDecoration('Enter your password',
                      errorText: passwordError),
                  obscureText: !_isPasswordVisible,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (passwordError == null) const SizedBox.shrink(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2b8761),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 350),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _login,
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
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
