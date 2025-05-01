import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/Onboarding/presentation/getStarted.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/register.dart';


PageRouteBuilder _buildSwipeRoute(String routeName) {
  return PageRouteBuilder(
    settings: RouteSettings(name: routeName),
    pageBuilder: (context, animation, secondaryAnimation) {
      // Since we're navigating to VerifySignup, return that widget
      return const GetStarted();
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




class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "Welcome To MedLink",
      "description":
          "Your digital bridge to better health. We connect you to nearby pharmacies, making it easier to access the medicine you need, right when you need it.",
      "image": "assets/images/onboarding1.png",
    },
    {
      "title": "Meds in Minutes",
      "description":
          "Find the closest pharmacy, check availability, and get your medicine in minutes. Because your time and health matter.",
      "image": "assets/images/onboarding2.png",
    },
    {
      "title": "Tailored Meds, Just for You",
      "description":
          "It's your healthcare companion. From urgent prescriptions to daily essentials, we bring the pharmacy to your fingertips.",
      "image": "assets/images/onboarding3.png",
    },
  ];

  void _goToNextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 30), // Space above navigation
            // Top Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentPage + 1}/${_slides.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                 
                    color:Color(0xFF2b8761),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    
                    _pageController.animateToPage(
                      _slides.length - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2b8761),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 65), 
            Image.asset(
              "assets/images/medLinkLogo.png",
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 50), 
            // PageView without Expanded
            SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.55, // Constrain height
              child: PageView.builder(
                // physics: BouncingScrollPhysics(),

                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align content at top
                    children: [
                      Image.asset(
                        slide["image"]!,
                        height: 300,
                      ),
                      const SizedBox(height: 20), // Reduced from 16
                      Text(
                        slide["title"]!,
                        style: GoogleFonts.poppins(
                          fontSize: 23,
                          color: const Color(0xFF2b8761),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        slide["description"]!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2b8761),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 50), 
            // Bottom Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "Prev" Button
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'Prev',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2b8761),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 48), // Placeholder for alignment
                // Page Indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 15,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            _currentPage == index ? Color(0xFF2b8761): Colors.grey,
                      ),
                    ),
                  ),
                ),
                // "Next" Button
                TextButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _goToNextPage();
                    } else {
                      Navigator.push(
                        context,
                        _buildSwipeRoute('/getStarted'),
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Start' : 'Next',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2b8761),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
