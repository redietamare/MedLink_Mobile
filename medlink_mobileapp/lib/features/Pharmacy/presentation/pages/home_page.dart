
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_state.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/pages/medicine_details_page.dart';
import 'package:medlink_mobileapp/service_locator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String token;
  late String email;
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _showRecommendations = false;
  final List<String> categories = [
    'All',
    'Pain Reliever',
    'Antibiotic',
    'Cold and Flu',
    'Vitamins',
    'Fever Reducer',
    'Cough Suppressant',
    'Antihistamine',
    'Antiseptic',
    'Anti Diabetic',
    'Anti Inflammatory',
    'Multi Vitamins',
    'Psychiatric',
    'Dermatological',
    'Neurological',
    'Respiratory',
    'Cardiovascular',
    'Gastrointestinal',
    'Anti hypertensive',
    'Anti Fungal',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    token = args?['token'] as String? ?? '';
    email = args?['email'] as String? ?? '';
    // Load all medicines by default for the "All" category
    context.read<MedicineBloc>().add(GetAllMedicinesEvent(token: token));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCategoryForApi(String category) {
    if (category == 'All') return 'all';
    return category.toLowerCase().replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<MedicineBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF2b8761)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
   
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFF2b8761),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF2b8761)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          email[0].toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFF2b8761),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email.split('@')[0],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title:
                    const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text('Recent Orders',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.white),
                title: const Text('Addresses',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.white),
                title: const Text('Notifications',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.gps_fixed, color: Colors.white),
                title: const Text('Location',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Settings',
                    style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        body: BlocConsumer<MedicineBloc, MedicineState>(
          listener: (context, state) {
            if (state is MedicineError &&
                state.message.contains('Unauthorized')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Session expired. Please log in again.')),
              );
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search medicine, Beauty care...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF2b8761)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon:
                              const Icon(Icons.clear, color: Color(0xFF2b8761)),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<MedicineBloc>()
                                .add(GetAllMedicinesEvent(token: token));
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<MedicineBloc>().add(
                              SearchMedicinesByNameEvent(
                                  token: token, name: value));
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Recommended Medicines
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showRecommendations = true;
                        });
                        context
                            .read<MedicineBloc>()
                            .add(GetUserRecommendationsEvent(token: token));
                      },
                      child: const Text(
                        'Recommended For You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2b8761),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_showRecommendations)
                      BlocBuilder<MedicineBloc, MedicineState>(
                        builder: (context, recommendationState) {
                          if (recommendationState is MedicineLoading) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF2b8761)));
                          } else if (recommendationState
                              is RecommendationsLoaded) {
                            if (recommendationState.medicines.isEmpty) {
                              return Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF94c2af), width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Finish filling your profile to get personalized recommendations.',
                                    style: TextStyle(
                                        color: Color(0xFF2b8761), fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendationState.medicines.length,
                                itemBuilder: (context, index) {
                                  final medicine =recommendationState.medicines[index];
                                                                    return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 8.0, bottom: 8.0), // Padding around each card
                                    child: _buildMedicineCard(medicine, context),
                                  );
                                },
                              ),
                            );
                          } else if (recommendationState is MedicineError) {
                            return Text('Error: ${recommendationState.message}',
                                style: const TextStyle(color: Colors.red));
                          }
                          return Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF94c2af), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Here you can find medicines tailored specifically for you.',
                                style: TextStyle(
                                    color: Color(0xFF2b8761), fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFF94c2af), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Here you can find medicines tailored specifically for you.',
                            style: TextStyle(
                                color: Color(0xFF2b8761), fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Categories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2b8761),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'SEE ALL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2b8761),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                                final formattedCategory =
                                    _formatCategoryForApi(category);
                                if (category == 'All') {
                                  context
                                      .read<MedicineBloc>()
                                      .add(GetAllMedicinesEvent(token: token));
                                } else {
                                  context
                                      .read<MedicineBloc>()
                                      .add(GetMedicinesByCategoryEvent(
                                        token: token,
                                        category: formattedCategory,
                                      ));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? const Color(0xFF2b8761)
                                    : const Color(0xFF94c2af),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(category),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Medicines Grid
                    BlocBuilder<MedicineBloc, MedicineState>(
                      builder: (context, state) {
                        if (state is MedicineLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF2b8761)));
                        } else if (state is MedicinesLoaded ||
                            state is SearchMedicinesLoaded) {
                          final medicines = state is MedicinesLoaded
                              ? state.medicines
                              : (state as SearchMedicinesLoaded).medicines;
                          if (medicines.isEmpty) {
                            return const Center(
                              child: Text(
                                'There is no medicine for now. We\'ll let you know when it\'s available.',
                                style: TextStyle(
                                    color: Color(0xFF2b8761), fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                            itemCount: medicines.length,
                            itemBuilder: (context, index) {
                              final medicine = medicines[index];
                              return _buildMedicineCard(medicine, context);
                            },
                          );
                        } else if (state is MedicineError) {
                          return Center(
                              child: Text('Error: ${state.message}',
                                  style: const TextStyle(color: Colors.red)));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine, BuildContext context) {
    final imageUrl = medicine.image != null
        ? 'https://medlink.yonathan.tech/api/user/image/${medicine.image}'
        : null;
    final placeholderAsset = 'assets/images/calcium.png';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MedicineDetailsPage(medicineId: medicine.id!, token: token),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFbF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      imageUrl != null
                          ? Image.network(
                              imageUrl,
                              height: 100,
                              width: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/onboarding1.png',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              placeholderAsset,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Availability badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: medicine.availability == 'in_stock'
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      medicine.availability == 'in_stock'
                          ? 'In Stock'
                          : 'Out of Stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2b8761),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (medicine.description != null &&
                      medicine.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        medicine.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${medicine.price?.toStringAsFixed(2) ?? '0.00'} Birr',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medicine.dosage ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medicine.form![0].toUpperCase()}${medicine.form?.substring(1) ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
