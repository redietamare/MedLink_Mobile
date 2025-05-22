
import 'package:medlink_mobileapp/features/Pharmacy/data/model/ai_model.dart';
import 'package:medlink_mobileapp/features/Pharmacy/data/model/medicine_model.dart';


abstract class AiState {}

class AiInitial extends AiState {}

class AiLoading extends AiState {}

class AiResponseLoaded extends AiState {
  final AiResponseModel response;

  AiResponseLoaded(this.response);
}

class MedicinesLoaded extends AiState {
  final List<MedicineModel> medicines;

  MedicinesLoaded(this.medicines);
}

class AiError extends AiState {
  final String message;

  AiError(this.message);
}
