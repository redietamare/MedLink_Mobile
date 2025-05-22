import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/cart_storage.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_state.dart';
import 'package:medlink_mobileapp/service_locator.dart';
import 'dart:io';

class MedicineDetailsPage extends StatefulWidget {
  final String medicineId;
  final String token;

  const MedicineDetailsPage({
    super.key,
    required this.medicineId,
    required this.token,
  });

  @override
  State<MedicineDetailsPage> createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  final TextEditingController _reviewController = TextEditingController();
  Medicine? _medicine;
  List<MedicineReview> _reviews = [];
  bool _showReviews = false;
  final ImagePicker _picker = ImagePicker();
  final CartStorage _cartStorage = CartStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = getIt<MedicineBloc>();
      if (!bloc.isClosed) {
        print('MedicineDetailsPage: Adding GetMedicineByIdEvent');
        bloc.add(GetMedicineByIdEvent(
            medicineId: widget.medicineId, token: widget.token));
      } else {
        print('MedicineDetailsPage: MedicineBloc is closed');
      }
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // Handle adding to cart
  void _handleAddToCart(BuildContext context) async {
    if (_medicine == null || _medicine!.availability != 'in_stock') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This medicine is out of stock.')),
      );
      return;
    }

    if (_medicine!.prescriptionRequired == true) {
      bool? uploaded = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Prescription Required',
            style: TextStyle(color: Color(0xFF2b8761)),
          ),
          content: const Text(
              'Upload prescription since it\'s required for this medicine.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  Navigator.pop(context, true);
                } else {
                  Navigator.pop(context, false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2b8761),
                foregroundColor: Colors.white,
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      );

      if (uploaded != true) return;
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      _selectQuantityAndAddToCart(context, prescriptionImagePath: image.path);
    } else {
      _selectQuantityAndAddToCart(context);
    }
  }

  // Show dialog to select quantity and add to cart
  void _selectQuantityAndAddToCart(BuildContext context,
      {String? prescriptionImagePath}) async {
    int quantity = 1;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setDialogState(() {
                          quantity--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$quantity', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () {
                      setDialogState(() {
                        quantity++;
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final cartItem = CartItem(
                  medicine: _medicine!,
                  quantity: quantity,
                  prescriptionImagePath: prescriptionImagePath,
                );
                final cartItems = await _cartStorage.getCartItems();
                cartItems.add(cartItem);
                await _cartStorage.saveCartItems(cartItems);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2b8761),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2b8761)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Medicine Details',
            style: TextStyle(
                color: Color(0xFF2b8761), fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<MedicineBloc, MedicineState>(
          listener: (context, state) {
            print('MedicineDetailsPage: State changed to $state');
            if (state is MedicineError &&
                state.message.contains('Unauthorized')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Session expired. Please log in again.')),
              );
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            } else if (state is SingleMedicineLoaded) {
              print('MedicineDetailsPage: Medicine: ${state.medicine}');
              setState(() {
                _medicine = state.medicine;
              });
            } else if (state is MedicineReviewsLoaded) {
              setState(() {
                _reviews = state.reviews;
                _showReviews = true;
              });
            } else if (state is MedicineReviewWritten) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review submitted successfully')),
              );
              context.read<MedicineBloc>().add(GetMedicineReviewsEvent(
                  medicineId: widget.medicineId, token: widget.token));
              _reviewController.clear();
            }
          },
          builder: (context, state) {
            if (state is MedicineLoading && _medicine == null) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2b8761)));
            } else if (_medicine != null) {
              final imageUrl = _medicine!.image != null
                  ? 'https://medlink.yonathan.tech/api/user/image/${_medicine!.image}'
                  : null;
              final placeholderAsset = 'assets/images/calcium.png';

              if (imageUrl != null) print('Loading image: $imageUrl');
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
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
                                width: 160,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _medicine!.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2b8761),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_medicine!.dosage != null)
                        Text(
                          'Dosage: ${_medicine!.dosage}',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      const SizedBox(height: 8),
                      if (_medicine!.description != null)
                        const Text(
                          'Description ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      Text(
                        _medicine!.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 13),
                      Row(
                        children: [
                          const Text(
                            'Price: ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${_medicine!.price?.toStringAsFixed(2) ?? '0.00'} Birr',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 13),
                      Row(
                        children: [
                          const Text(
                            'Availability: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _medicine!.availability == 'in_stock'
                                ? 'In Stock'
                                : 'Out of Stock',
                            style: TextStyle(
                              fontSize: 16,
                              color: _medicine!.availability == 'in_stock'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 13),
                      Row(
                        children: [
                          const Text(
                            'Prescription Required: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            _medicine!.prescriptionRequired == true
                                ? 'Yes'
                                : 'No',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 13),
                      Row(
                        children: [
                          const Text(
                            'Located at: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _medicine!.pharmacyName ?? 'Medlink Pharmacy',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          const Text(
                            'Manufactured Date: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${_medicine!.manufacturedDate?.toIso8601String().split('T').first ?? '2024-01-15'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      SizedBox(height: 13),
                      Row(
                        children: [
                          const Text(
                            'Expiration Date: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${_medicine!.expiryDate?.toIso8601String().split('T').first ?? '2024-01-15'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showReviews = !_showReviews;
                                if (_showReviews && _reviews.isEmpty) {
                                  context.read<MedicineBloc>().add(
                                      GetMedicineReviewsEvent(
                                          medicineId: widget.medicineId,
                                          token: widget.token));
                                }
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  _showReviews
                                      ? 'Hide Reviews'
                                      : 'View Reviews',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2b8761),
                                  ),
                                ),
                                Icon(
                                  _showReviews
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF2b8761),
                                ),
                              ],
                            ),
                          ),
                          if (_showReviews)
                            _reviews.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'No reviews yet.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _reviews.length,
                                    itemBuilder: (context, index) {
                                      final review = _reviews[index];
                                      return ListTile(
                                        title: Text(
                                          review.name ?? 'Anonymous',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(review.message ?? ''),
                                        trailing: Text(review.date ?? ''),
                                      );
                                    },
                                  ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Write a Review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2b8761),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reviewController,
                        decoration: InputDecoration(
                          hintText: 'Enter your review...',
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
                          if (_reviewController.text.isNotEmpty) {
                            context.read<MedicineBloc>().add(
                                WriteMedicineReviewEvent(
                                    medicineId: widget.medicineId,
                                    message: _reviewController.text,
                                    token: widget.token));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2b8761),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(40, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Submit Review'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _handleAddToCart(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2b8761), // Base color
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4, // Subtle shadow
                        ).copyWith(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color(0xFF1f6a4a).withOpacity(
                                    0.9); // Darker shade when pressed
                              }
                              if (states.contains(MaterialState.hovered)) {
                                return const Color(
                                    0xFF34986c); // Lighter shade on hover
                              }
                              return const Color(0xFF2b8761); // Default color
                            },
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is MedicineError) {
              return Center(
                  child: Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
