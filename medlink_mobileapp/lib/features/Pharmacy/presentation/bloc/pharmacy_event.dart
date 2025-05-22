
import 'package:equatable/equatable.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/usecase/pharmacy_usecase.dart';


abstract class PharmacyEvent extends Equatable {
  const PharmacyEvent();

  @override
  List<Object> get props => [];
}

class GetAllPharmaciesEvent extends PharmacyEvent {
  final String token;
  const GetAllPharmaciesEvent({required this.token});
  @override
  List<Object> get props => [token];
}

class GetPharmacyByIdEvent extends PharmacyEvent {
  final String pharmacyId;
  final String token;
  const GetPharmacyByIdEvent({required this.pharmacyId, required this.token});
  @override
  List<Object> get props => [pharmacyId, token];
}

class GetPharmacyReviewsEvent extends PharmacyEvent {
  final String pharmacyId;
  final String token;
  const GetPharmacyReviewsEvent({required this.pharmacyId, required this.token});
  @override
  List<Object> get props => [pharmacyId, token];
}

class WritePharmacyReviewEvent extends PharmacyEvent {
  final WritePharmacyReviewParams params;
  const WritePharmacyReviewEvent({required this.params});
  @override
  List<Object> get props => [params];
}

class GetPharmacyProductsEvent extends PharmacyEvent {
  final String pharmacyId;
  final String token;
  const GetPharmacyProductsEvent({required this.pharmacyId, required this.token});
  @override
  List<Object> get props => [pharmacyId, token];
}
