class Medicine {
  final String? id;
  final String? pharmacyId;
  final String? pharmacyName;
  final String? name;
  final String? description;
  final String? dosage;
  final String? form;
  final bool? prescriptionRequired;
  final String? availability;
  final String? category;
  final double? price;
  final int? quantity;
  final String? image;
  final String? batchNumber;
  final DateTime? manufacturedDate;
  final DateTime? expiryDate;
  final String? storageInstructions;

  Medicine({
    this.id,
    this.pharmacyId,
    this.pharmacyName,
    this.name,
    this.description,
    this.dosage,
    this.form,
    this.prescriptionRequired,
    this.availability,
    this.category,
    this.price,
    this.quantity,
    this.image,
    this.batchNumber,
    this.manufacturedDate,
    this.expiryDate,
    this.storageInstructions,
  });
  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, description: $description, dosage: $dosage, '
           'form: $form, prescriptionRequired: $prescriptionRequired, availability: $availability, '
           'category: $category, price: $price, quantity: $quantity, image: $image, '
           'pharmacyId: $pharmacyId, pharmacyName: $pharmacyName, batchNumber: $batchNumber, '
           'manufacturedDate: $manufacturedDate, expiryDate: $expiryDate, '
           'storageInstructions: $storageInstructions)';
  }
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String?,
      pharmacyId: json['pharmacy_id'] as String?,
      pharmacyName: json['pharmacy_name'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      dosage: json['dosage'] as String?,
      form: json['form'] as String?,
      prescriptionRequired: json['prescription_required'] as bool?,
      availability: json['availability'] as String?,
      category: json['category'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      quantity: json['quantity'] as int?,
      image: json['image'] as String?,
      batchNumber: json['batch_number'] as String?,
      manufacturedDate: json['manufactured_date'] != null
          ? DateTime.parse(json['manufactured_date'] as String)
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      storageInstructions: json['storage_instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacy_id': pharmacyId,
      'pharmacy_name': pharmacyName,
      'name': name,
      'description': description,
      'dosage': dosage,
      'form': form,
      'prescription_required': prescriptionRequired,
      'availability': availability,
      'category': category,
      'price': price,
      'quantity': quantity,
      'image': image,
      'batch_number': batchNumber,
      'manufactured_date': manufacturedDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'storage_instructions': storageInstructions,
    }..removeWhere((key, value) => value == null);
  }
}

class MedicineReview {
  final String? id;
  final String? name;
  final String? message;
  final String? date;
  final bool? my;

  MedicineReview({
    this.id,
    this.name,
    this.message,
    this.date,
    this.my,
  });

  factory MedicineReview.fromJson(Map<String, dynamic> json) {
    return MedicineReview(
      id: json['id'] as String?,
      name: json['name'] as String?,
      message: json['message'] as String?,
      date: json['date'] as String?,
      my: json['my'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'date': date,
      'my': my,
    }..removeWhere((key, value) => value == null);
  }
}