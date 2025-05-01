import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
    return Scaffold(
      backgroundColor: Color(0xFF2b8761),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your app logo or image
            Image.asset(
              'assets/images/splash.png',
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
         
          ],
        ),
      ),
    );
  }
}
