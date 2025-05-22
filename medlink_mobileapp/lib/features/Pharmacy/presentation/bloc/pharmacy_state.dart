
import 'package:equatable/equatable.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/pharmacy_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';

abstract class PharmacyState extends Equatable {
  const PharmacyState();

  @override
  List<Object> get props => [];
}

class PharmacyInitial extends PharmacyState {}

class PharmacyLoading extends PharmacyState {}

class PharmaciesLoaded extends PharmacyState {
  final List<Pharmacy> pharmacies;
  const PharmaciesLoaded(this.pharmacies);
  @override
  List<Object> get props => [pharmacies];
}

class SinglePharmacyLoaded extends PharmacyState {
  final Pharmacy pharmacy;
  const SinglePharmacyLoaded(this.pharmacy);
  @override
  List<Object> get props => [pharmacy];
}

class PharmacyReviewsLoaded extends PharmacyState {
  final List<PharmacyReview> reviews;
  const PharmacyReviewsLoaded(this.reviews);
  @override
  List<Object> get props => [reviews];
}

class PharmacyReviewWritten extends PharmacyState {}

class PharmacyProductsLoaded extends PharmacyState {
  final List<Medicine> medicines;
  const PharmacyProductsLoaded(this.medicines);
  @override
  List<Object> get props => [medicines];
}

class PharmacyError extends PharmacyState {
  final String message;
  const PharmacyError(this.message);
  @override
  List<Object> get props => [message];
}
