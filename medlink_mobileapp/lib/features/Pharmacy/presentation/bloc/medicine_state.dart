import 'package:equatable/equatable.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicinesLoaded extends MedicineState {
  final List<Medicine> medicines;

  const MedicinesLoaded(this.medicines);

  @override
  List<Object> get props => [medicines];
}

class SingleMedicineLoaded extends MedicineState {
  final Medicine medicine;

  const SingleMedicineLoaded(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class MedicineReviewsLoaded extends MedicineState {
  final List<MedicineReview> reviews;

  const MedicineReviewsLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class MedicineReviewWritten extends MedicineState {}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object> get props => [message];
}

class SearchMedicinesLoaded extends MedicineState {
  final List<Medicine> medicines;

  const SearchMedicinesLoaded(this.medicines);

  @override
  List<Object> get props => [medicines];
}

class RecommendationsLoaded extends MedicineState {
  final List<Medicine> medicines;

  const RecommendationsLoaded(this.medicines);

  @override
  List<Object> get props => [medicines];
}