import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/home_page.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/profile_page.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:medlink_mobileapp/features/auth/presentation/bloc/user_bloc.dart';

class PrescriptionPage extends StatelessWidget {
  const PrescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Prescription Page'));
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Cart Page'));
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Favorites Page'));
  }
}

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve email from AuthState
    final authState = context.watch<UserBloc>().state;
    if (authState is AuthAuthenticated) {
      email = authState.user.email;
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
        break;
      case 1:
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/prescription', (route) => false);
        break;
      case 2:
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/cart', (route) => false);
        break;
      case 3:
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/favorites', (route) => false);
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
            const SnackBar(content: Text('Authentication token not found. Please log in again.')),
          );
          _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/home',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/home':
              page = HomePage();
              break;
            case '/prescription':
              page = const Center(child: Text('Prescription Page'));
              break;
            case '/cart':
              page = const Center(child: Text('Cart Page'));
              break;
            case '/favorites':
              page = const Center(child: Text('Favorites Page'));
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Prescription'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2b8761),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}