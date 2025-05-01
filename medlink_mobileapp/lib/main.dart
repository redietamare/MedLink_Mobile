import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medlink_mobileapp/features/Onboarding/presentation/Onbording.dart';
import 'package:medlink_mobileapp/features/Onboarding/presentation/getStarted.dart';
import 'package:medlink_mobileapp/features/Onboarding/presentation/splash_screen.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/login.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/register.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/reset_new_password.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/verified_page.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/verify_signup.dart';
import 'package:medlink_mobileapp/features/auth/presentation/pages/forgot_password.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/home_page.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/main_page.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/profile_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/profile_page.dart';
import 'package:medlink_mobileapp/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<UserBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ProfileBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/splashScreen',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/splashScreen':
              page = SplashScreen();
              break;
            case '/onboarding':
              page = const OnboardingScreen();
              break;
            case '/getStarted':
              page = const GetStarted();
              break;
            case '/register':
              page = const RegisterScreen();
              break;
            case '/verify-signup':
              page = const VerifySignup();
              break;
            case '/login':
              page = const LoginPage();
              break;
            case '/verified':
              page = const VerifiedPage();
              break;
            case '/forgot-password':
              page = const ForgotPassword();
              break;
            case '/reset-new-password':
              page = const ResetNewPassword();
              break;
            case '/main-page':
              page = const MainPage();
              break;
            case '/home':
              page = const HomePage();
              break;
            case '/prescription':
              page = const PrescriptionPage();
              break;
            case '/cart':
              page = const CartPage();
              break;
            case '/favorites':
              page = const FavoritesPage();
              break;
            case '/personal-profile':
              final args = settings.arguments as Map<String, dynamic>;
              page = PersonalProfile();
              break;
            default:
              page = const Center(child: Text('Page Not Found'));
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
    );
  }
}