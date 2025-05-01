import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    transitionDuration:
        const Duration(milliseconds: 500), 
  );
}


class VerifiedPage extends StatefulWidget {
  const VerifiedPage({super.key});

  @override
  State<VerifiedPage> createState() => _VerifiedPageState();
}

class _VerifiedPageState extends State<VerifiedPage> {
late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    email = args?['email'] as String? ?? ''; // Fallback to empty string if email is not provided
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2b8761)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Image.asset(
            "assets/images/medLinkLogo.png",
            height: 60,
            width: 60,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 30),
          Image.asset(
            "assets/images/verified.png",
            height: 250,
            width: 250,
            fit: BoxFit.contain,
          ),
          Text(
            'Account Successfully Created.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Welcome To MedLink',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2b8761),
            ),
          ),
          SizedBox(height: 280),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, _buildSwipeRoute('/login', {'email': email}));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2b8761),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Start Now',
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
  }
}