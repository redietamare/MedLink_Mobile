import 'package:equatable/equatable.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object> get props => [];
}

class GetAllMedicinesEvent extends MedicineEvent {
  final String token;

  const GetAllMedicinesEvent({required this.token});

  @override
  List<Object> get props => [token];
}

class SearchMedicinesByNameEvent extends MedicineEvent {
  final String token;
  final String name;

  const SearchMedicinesByNameEvent({required this.token, required this.name});

  @override
  List<Object> get props => [token, name];
}

class GetMedicinesByCategoryEvent extends MedicineEvent {
  final String token;
  final String category;

  const GetMedicinesByCategoryEvent({required this.token, required this.category});

  @override
  List<Object> get props => [token, category];
}

class GetMedicineByIdEvent extends MedicineEvent {
  final String medicineId;
  final String token;

  const GetMedicineByIdEvent({required this.medicineId, required this.token});

  @override
  List<Object> get props => [medicineId, token];
}

class WriteMedicineReviewEvent extends MedicineEvent {
  final String medicineId;
  final String message;
  final String token;

  const WriteMedicineReviewEvent({
    required this.medicineId,
    required this.message,
    required this.token,
  });

  @override
  List<Object> get props => [medicineId, message, token];
}

class GetMedicineReviewsEvent extends MedicineEvent {
  final String medicineId;
  final String token;

  const GetMedicineReviewsEvent({required this.medicineId, required this.token});

  @override
  List<Object> get props => [medicineId, token];
}

class GetUserRecommendationsEvent extends MedicineEvent {
  final String token;
  
  const GetUserRecommendationsEvent({required this.token});

  @override
  List<Object> get props => [token];
}