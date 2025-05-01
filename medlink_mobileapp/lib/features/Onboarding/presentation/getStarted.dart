import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/login.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/register.dart';

PageRouteBuilder _buildSwipeRoute(String routeName) {
  return PageRouteBuilder(
    settings: RouteSettings(name: routeName),
    pageBuilder: (context, animation, secondaryAnimation) {
      // Since we're navigating to VerifySignup, return that widget
      return const RegisterScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the swipe animation (right to left)
      const begin = Offset(1.0, 0.0); // Start from the right
      const end = Offset.zero; // End at the center
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
        
      );
    },
    transitionDuration: const Duration(milliseconds: 800), // Duration of the animation
  );
}

PageRouteBuilder _buildSwipeRoute2(String routeName) {
  return PageRouteBuilder(
    settings: RouteSettings(name: routeName),
    pageBuilder: (context, animation, secondaryAnimation) {
      // Since we're navigating to VerifySignup, return that widget
      return const LoginPage();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the swipe animation (right to left)
      const begin = Offset(1.0, 0.0); // Start from the right
      const end = Offset.zero; // End at the center
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
        
      );
    },
    transitionDuration: const Duration(milliseconds: 800), // Duration of the animation
  );
}

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2b8761)),
          onPressed: () {
            Navigator.pushNamed(context, '/onboarding');
          },
        ),
      ),
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(height: 10),
            Image.asset(
              "assets/images/medlink.png",
              height: 170,
              width: 170,
              fit: BoxFit.contain,
            ),
            Image.asset(
              'assets/images/onboarding4.png',
              height: 300,
              width: 300,
            ),
            SizedBox(height: 70),
            ElevatedButton(
            onPressed:() {
                Navigator.push(context, _buildSwipeRoute('/register'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 140, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Color(0xFF2b8761), width: 1.5),

              ),
            ),
            child: Text('Register',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2b8761),
              )
            ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
            onPressed:() {
              Navigator.push(context, _buildSwipeRoute2('/login'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2b8761),
              padding: EdgeInsets.symmetric(horizontal: 155, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Color(0xFF2b8761), width: 1.5),

              ),
            ),
            child: Text('Login',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              )
            ),
            ),

          ],
        ),

      )

    );
  }
}