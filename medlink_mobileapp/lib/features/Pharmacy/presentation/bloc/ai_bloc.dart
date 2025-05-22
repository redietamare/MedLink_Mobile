
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/usecase/ai_usecase.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/ai_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/ai_state.dart';


class AiBloc extends Bloc<AiEvent, AiState> {
  final AskAiUseCase askAiUseCase;
  final GetMedicineByNameUseCase getMedicineByNameUseCase;

  AiBloc({
    required this.askAiUseCase,
    required this.getMedicineByNameUseCase,
  }) : super(AiInitial()) {
    on<AskAiEvent>((event, emit) async {
      emit(AiLoading());
      try {
        final response = await askAiUseCase(
          AskAiParams(description: event.description, token: event.token),
        );
        emit(AiResponseLoaded(response));
        emit(AiInitial()); // Reset state after response
      } catch (e) {
        emit(AiError(e.toString()));
        emit(AiInitial()); // Reset state after error
      }
    });

    on<GetMedicineByNameEvent>((event, emit) async {
      emit(AiLoading());
      try {
        final medicines = await getMedicineByNameUseCase(
          GetMedicineByNameParams(name: event.name, token: event.token),
        );
        emit(MedicinesLoaded(medicines));
        emit(AiInitial()); // Reset state after navigation
      } catch (e) {
        emit(AiError(e.toString()));
        emit(AiInitial()); // Reset state after error
      }
    });
  }
}