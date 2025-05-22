import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/ai_page.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/cart_page.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/home_page.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/pharmacy_page.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/profile_page.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';




class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String email = '';
  @override
  void initState() {
    super.initState();
    // Fetch token and navigate to home with arguments
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await context.read<UserBloc>().getAccessToken();
      if (token != null && mounted) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: {'email': email, 'token': token},
        );
      } else {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve email from AuthState
    final authState = context.watch<UserBloc>().state;
    if (authState is AuthAuthenticated) {
      email = authState.user.email;
    }
  }

  void _onItemTapped(int index) async {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        final token = await context.read<UserBloc>().getAccessToken();
        if (token != null) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
            arguments: {'email': email, 'token': token},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Authentication token not found. Please log in again.')),
          );
          _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
        break;
      case 1:
        final token = await context.read<UserBloc>().getAccessToken();
        if (token != null) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/ai-chat-bot',
            (route) => false,
            arguments: {'email': email, 'token': token},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Authentication token not found. Please log in again.')),
          );
          _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
        break;
      case 2:
        final token = await context.read<UserBloc>().getAccessToken();
        if (token != null) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/pharmacy',
            (route) => false,
            arguments: {'email': email, 'token': token},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Authentication token not found. Please log in again.')),
          );
          _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
        break;
      case 3:
        _navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/cart', (route) => false);
        break;
      case 4:
        // Retrieve the token before navigating
        final token = await context.read<UserBloc>().getAccessToken();
        if (token != null) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/personal-profile',
            (route) => false,
            arguments: {'email': email, 'token': token},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Authentication token not found. Please log in again.')),
          );
          _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/home':
              final args = settings.arguments as Map<String, dynamic>;
              page = HomePage();
              break;
            case '/ai-chat-bot':
              final args = settings.arguments as Map<String, dynamic>;
              page = AiChatbot();
              break;
            case '/pharmacy':
              final args = settings.arguments as Map<String, dynamic>;
              page = PharmacyPage();
              break;
            case '/cart':
              page = CartPage();
              break;
            case '/personal-profile':
              final args = settings.arguments as Map<String, dynamic>;
              // page = PersonalProfile(token: args['token'] as String);
              page = PersonalProfile();
              break;
            default:
              page = const Center(child: Text('Page Not Found'));
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2b8761),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/home.png', width: 28, height: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/ai.png', width: 26, height: 26),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/pharmacy.png',
                width: 26, height: 26),
            label: 'Pharmacy',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/cart.png', width: 26, height: 26),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFF2b8761)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
