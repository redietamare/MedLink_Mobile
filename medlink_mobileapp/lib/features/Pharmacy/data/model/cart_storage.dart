import 'dart:convert';
import 'dart:io';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final Medicine medicine;
  final int quantity;
  final String? prescriptionImagePath;

  CartItem({
    required this.medicine,
    required this.quantity,
    this.prescriptionImagePath,
  });

  Map<String, dynamic> toJson() => {
        'medicine': {
          'id': medicine.id,
          'name': medicine.name,
          'dosage': medicine.dosage,
          'price': medicine.price,
          'availability': medicine.availability,
          'image': medicine.image,
          'prescriptionRequired': medicine.prescriptionRequired,
        },
        'quantity': quantity,
        'prescriptionImagePath': prescriptionImagePath,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      medicine: Medicine(
        id: json['medicine']['id'] as String?,
        name: json['medicine']['name'] as String?,
        dosage: json['medicine']['dosage'] as String?,
        price: json['medicine']['price'] as double?,
        availability: json['medicine']['availability'] as String?,
        image: json['medicine']['image'] as String?,
        prescriptionRequired: json['medicine']['prescriptionRequired'] as bool?,
      ),
      quantity: json['quantity'] as int,
      prescriptionImagePath: json['prescriptionImagePath'] as String?,
    );
  }
}

class CartStorage {
  static const String _cartKey = 'cart_items';

  Future<void> saveCartItems(List<CartItem> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_cartKey, cartJson);
  }

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList(_cartKey) ?? [];
    return cartJson
        .map((json) => CartItem.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}