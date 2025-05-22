import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/pharmacy_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/usecase/pharmacy_usecase.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/pharmacy_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/pharmacy_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/pharmacy_state.dart';
import 'package:medlink_mobileapp/service_locator.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  late String token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['token'] != null) {
      token = args['token'] as String;
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = getIt<PharmacyBloc>();
      if (!bloc.isClosed) {
        bloc.add(GetAllPharmaciesEvent(token: token));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PharmacyBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Pharmacies',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2b8761),
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<PharmacyBloc, PharmacyState>(
          listener: (context, state) {
            if (state is PharmacyError &&
                state.message.contains('Unauthorized')) {
              print('Session expired. Please log in again.');
              print(token);
              print(state.message);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Session expired. Please log in again.')),
              );
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
          builder: (context, state) {
            if (state is PharmacyLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2b8761)));
            } else if (state is PharmaciesLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = state.pharmacies[index];
                  return _buildPharmacyCard(context, pharmacy);
                },
              );
            } else if (state is PharmacyError) {
              return Center(
                  child: Text('Error: ${state.message}',
                      style: GoogleFonts.poppins(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(BuildContext context, Pharmacy pharmacy) {
    final imageUrl = pharmacy.pharmacyLogo != null
        ? 'https://medlink.yonathan.tech/api/user/image/${pharmacy.pharmacyLogo}'
        : null;
    final addressString = pharmacy.address.street.isNotEmpty
        ? '${pharmacy.address.street}, ${pharmacy.address.city}, ${pharmacy.address.state} ${pharmacy.address.zipCode}'
        : 'Address not available';

    return GestureDetector(
      child: Card(
        color: Color(0xFFfffbf5),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF2b8761)));
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/placeholder.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacy.pharmacyName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2b8761),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          addressString,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Distance: ${pharmacy.distance?.toStringAsFixed(2) ?? 'N/A'} km',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PharmacyDetailsPage(),
            settings: RouteSettings(
              arguments: {
                'pharmacyId': pharmacy.id,
                'token': token,
              },
            ),
          ),
        );
      },
    );
  }
}

class PharmacyDetailsPage extends StatefulWidget {
  const PharmacyDetailsPage({super.key});

  @override
  State<PharmacyDetailsPage> createState() => _PharmacyDetailsPageState();
}

class _PharmacyDetailsPageState extends State<PharmacyDetailsPage> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  Pharmacy? _pharmacy;
  List<PharmacyReview> _reviews = [];
  List<Medicine> _products = [];
  bool _showReviews = false;
  bool _showProducts = false;
  late String pharmacyId;
  late String token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['pharmacyId'] != null && args['token'] != null) {
      pharmacyId = args['pharmacyId'] as String;
      token = args['token'] as String;
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = getIt<PharmacyBloc>();
      if (!bloc.isClosed) {
        bloc.add(GetPharmacyByIdEvent(pharmacyId: pharmacyId, token: token));
      }
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PharmacyBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2b8761)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pharmacy Details',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2b8761),
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocConsumer<PharmacyBloc, PharmacyState>(
          listener: (context, state) {
            if (state is PharmacyError &&
                state.message.contains('Unauthorized')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Session expired. Please log in again.')),
              );
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            } else if (state is SinglePharmacyLoaded) {
              setState(() {
                _pharmacy = state.pharmacy;
              });
            } else if (state is PharmacyReviewsLoaded) {
              setState(() {
                _reviews = state.reviews;
                _showReviews = true;
              });
            } else if (state is PharmacyReviewWritten) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review submitted successfully')),
              );
              context.read<PharmacyBloc>().add(GetPharmacyReviewsEvent(
                    pharmacyId: pharmacyId,
                    token: token,
                  ));
              _reviewController.clear();
              _ratingController.clear();
            } else if (state is PharmacyProductsLoaded) {
              setState(() {
                _products = state.medicines;
                _showProducts = true;
              });
            }
          },
          builder: (context, state) {
            if (state is PharmacyLoading && _pharmacy == null) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2b8761)));
            } else if (_pharmacy != null) {
              final imageUrl = _pharmacy!.pharmacyLogo != null
                  ? 'https://medlink.yonathan.tech/api/user/image/${_pharmacy!.pharmacyLogo}'
                  : null;
              final addressString = _pharmacy!.address.street.isNotEmpty
                  ? '${_pharmacy!.address.street}, ${_pharmacy!.address.city}, ${_pharmacy!.address.state} ${_pharmacy!.address.zipCode}'
                  : 'Address not available';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF2b8761)));
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/placeholder.png',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/placeholder.png',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _pharmacy!.pharmacyName,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2b8761),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: const Color(0xFFfffbf5),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  'Address',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2b8761),
                                  ),
                                ),
                                subtitle: Text(
                                  addressString,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Description',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2b8761),
                                  ),
                                ),
                                subtitle: Text(
                                  _pharmacy!.description ??
                                      'No description available',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Open Hours',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2b8761),
                                  ),
                                ),
                                subtitle: _pharmacy!.openHours != null &&
                                        _pharmacy!.openHours!.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            _pharmacy!.openHours!.map((hour) {
                                          return Text(
                                            '${hour.day}: ${hour.open} - ${hour.close}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          );
                                        }).toList(),
                                      )
                                    : Text(
                                        'No open hours available',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                              ),
                              ListTile(
                                title: Text(
                                  'Delivery',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2b8761),
                                  ),
                                ),
                                subtitle: Text(
                                  _pharmacy!.delivery
                                      ? 'Supported'
                                      : 'Not Supported',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Status',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2b8761),
                                  ),
                                ),
                                subtitle: Text(
                                  _pharmacy!.isOpen ? 'Open' : 'Closed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: _pharmacy!.isOpen
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Closes',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2b8761),
                                  ),
                                ),
                                subtitle: Text(
                                  _pharmacy!.closes ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Phone Number',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2b8761),
                                  ),
                                ),
                                subtitle: Text(
                                  _pharmacy!.phoneNumber ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // View Products Toggle Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showProducts = !_showProducts;
                            if (_showProducts && _products.isEmpty) {
                              context
                                  .read<PharmacyBloc>()
                                  .add(GetPharmacyProductsEvent(
                                    pharmacyId: pharmacyId,
                                    token: token,
                                  ));
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2b8761),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(40, 40),
                        ),
                        child: Text(
                          _showProducts ? 'Hide Products' : 'View Products',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                      if (_showProducts) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Products',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2b8761),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _products.isEmpty
                            ? Text(
                                'No products available.',
                                style: GoogleFonts.poppins(color: Colors.grey),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _products.length,
                                itemBuilder: (context, index) {
                                  final product = _products[index];
                                  final productImageUrl = product.image != null
                                      ? 'https://medlink.yonathan.tech/api/user/image/${product.image}'
                                      : null;
                                  return Card(
                                    color: const Color(0xFFfffbf5),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: productImageUrl != null
                                              ? Image.network(
                                                  productImageUrl,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Color(
                                                                    0xFF2b8761)));
                                                  },
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(
                                                    'assets/images/placeholder.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/images/placeholder.png',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      title: Text(
                                        product.name ?? 'Unknown Product',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        '${product.price?.toStringAsFixed(2)} Birr',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                      const SizedBox(height: 16),
                      // View Reviews Toggle Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showReviews = !_showReviews;
                            if (_showReviews && _reviews.isEmpty) {
                              context
                                  .read<PharmacyBloc>()
                                  .add(GetPharmacyReviewsEvent(
                                    pharmacyId: pharmacyId,
                                    token: token,
                                  ));
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2b8761),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(40, 40),
                        ),
                        child: Text(
                          _showReviews ? 'Hide Reviews' : 'View Reviews',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                      if (_showReviews) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Reviews',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2b8761),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _reviews.isEmpty
                            ? Text(
                                'No reviews yet.',
                                style: GoogleFonts.poppins(color: Colors.grey),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _reviews.length,
                                itemBuilder: (context, index) {
                                  final review = _reviews[index];
                                  return ListTile(
                                    title: Text(
                                      review.name ?? 'Anonymous',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      review.content ?? '',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    trailing: Text(
                                      'Rating: ${review.rate}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                },
                              ),
                      ],
                      const SizedBox(height: 16),
                      // Write a Review Section
                      Text(
                        'Write a Review',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2b8761),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ratingController,
                        decoration: InputDecoration(
                          hintText: 'Enter rating (1-5)',
                          hintStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reviewController,
                        decoration: InputDecoration(
                          hintText: 'Enter your review...',
                          hintStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_reviewController.text.isNotEmpty &&
                              _ratingController.text.isNotEmpty) {
                            final rate = int.tryParse(_ratingController.text);
                            if (rate != null && rate >= 1 && rate <= 5) {
                              context
                                  .read<PharmacyBloc>()
                                  .add(WritePharmacyReviewEvent(
                                    params: WritePharmacyReviewParams(
                                      pharmacyId: pharmacyId,
                                      rate: rate,
                                      content: _reviewController.text,
                                      token: token,
                                    ),
                                  ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please enter a valid rating between 1 and 5')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2b8761),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text('Submit Review',
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            } else if (state is PharmacyError) {
              return Center(
                  child: Text('Error: ${state.message}',
                      style: GoogleFonts.poppins(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
