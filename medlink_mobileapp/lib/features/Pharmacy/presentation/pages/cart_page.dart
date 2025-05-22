import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/cart_storage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartStorage _cartStorage = CartStorage();
  List<CartItem> _cartItems = [];
  double _subtotal = 0.0;
  double _deliveryFee = 0.0;
  double _total = 0.0;
  bool _isOrderPlaced = false;
  String _orderStatus = 'Prescription Review'; // Initial status
  bool _showOrderTracking = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final cartItems = await _cartStorage.getCartItems();
    setState(() {
      _cartItems = cartItems;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _subtotal = _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.medicine.price ?? 0.0) * item.quantity,
    );
    _deliveryFee = _subtotal * 0.3; // 30% of subtotal
    _total = _subtotal + _deliveryFee;
  }

  Future<void> _removeItem(int index) async {
    setState(() {
      _cartItems.removeAt(index);
    });
    await _cartStorage.saveCartItems(_cartItems);
    _calculateTotals();
  }

  Future<void> _placeOrder() async {
    setState(() {
      _isOrderPlaced = true;
      _showOrderTracking = true;
    });

    // Prescription Review (5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    setState(() {
      _orderStatus = 'Order Confirmed';
    });

    // Order Confirmed (5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    setState(() {
      _orderStatus = 'Pharmacy Preparing';
    });

    // Pharmacy Preparing (5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    setState(() {
      _orderStatus = 'Driver Started Trip';
    });

    // Driver Started Trip (5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    setState(() {
      _orderStatus = 'Driver Is Here';
    });

    // Driver Is Here (5 seconds)
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    setState(() {
      _orderStatus = 'Your Order Is Here';
    });

    // Clear cart after order completion
    await _cartStorage.clearCart();
    setState(() {
      _cartItems = [];
      _subtotal = 0.0;
      _deliveryFee = 0.0;
      _total = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Color(0xFF2b8761),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isOrderPlaced && _showOrderTracking
          ? _buildOrderTracking()
          : _cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final imageUrl = item.medicine.image != null
                              ? 'https://medlink.yonathan.tech/images/${item.medicine.image}'
                              : 'assets/images/placeholder.png';
                          return Card(
                            color: const Color(0xFFfffbf5),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.network(
                                        item.medicine.image != null
                                            ? 'https://medlink.yonathan.tech/api/user/image/${item.medicine.image}'
                                            : 'assets/images/placeholder.png',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.medicine.name ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2b8761),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Quantity: ${item.quantity}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        Text(
                                          'Price: ${(item.medicine.price ?? 0.0).toStringAsFixed(2)} Birr',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        if (item.prescriptionImagePath != null)
                                          const Text(
                                            'Prescription Uploaded',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        _isOrderPlaced ? null : () => _removeItem(index),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2b8761),
                                ),
                              ),
                              Text(
                                '${_subtotal.toStringAsFixed(2)} Birr',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2b8761),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Delivery Fee (30%):',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2b8761),
                                ),
                              ),
                              Text(
                                '${_deliveryFee.toStringAsFixed(2)} Birr',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2b8761),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2b8761),
                                ),
                              ),
                              Text(
                                '${_total.toStringAsFixed(2)} Birr',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2b8761),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _cartItems.isEmpty ? null : _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2b8761),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Place Order'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildOrderTracking() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_shipping,
              size: 80,
              color: Color(0xFF2b8761),
            ),
            const SizedBox(height: 16),
            Text(
              _orderStatus,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2b8761),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_orderStatus != 'Your Order Is Here')
              const CircularProgressIndicator(
                color: Color(0xFF2b8761),
              )
            else
              Column(
                children: [
                  const Text(
                    'Pick it up!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showOrderTracking = false;
                        _isOrderPlaced = false;
                        _orderStatus = 'Prescription Review';
                      });
                      Navigator.pop(context); // Return to previous page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2b8761),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}