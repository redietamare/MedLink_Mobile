import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/usecase/medicine_usecase.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/medicine_state.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/medicine.dart';



class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final GetAllMedicines getAllMedicines;
  final SearchMedicinesByName searchMedicinesByName;
  final GetMedicinesByCategory getMedicinesByCategory;
  final GetMedicineById getMedicineById;
  final WriteMedicineReview writeMedicineReview;
  final GetMedicineReviews getMedicineReviews;
  final GetUserRecommendations getUserRecommendations;

  MedicineBloc({
    required this.getAllMedicines,
    required this.searchMedicinesByName,
    required this.getMedicinesByCategory,
    required this.getMedicineById,
    required this.writeMedicineReview,
    required this.getMedicineReviews,
    required this.getUserRecommendations,
  }) : super(MedicineInitial()) {
    on<GetAllMedicinesEvent>(_onGetAllMedicines);
    on<SearchMedicinesByNameEvent>(_onSearchMedicinesByName);
    on<GetMedicinesByCategoryEvent>(_onGetMedicinesByCategory);
    on<GetMedicineByIdEvent>(_onGetMedicineById);
    on<WriteMedicineReviewEvent>(_onWriteMedicineReview);
    on<GetMedicineReviewsEvent>(_onGetMedicineReviews);
    on<GetUserRecommendationsEvent>(_onGetUserRecommendations);
  }

  Future<void> _onGetAllMedicines(GetAllMedicinesEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final result = await getAllMedicines(token: event.token);
    result.fold(
      (failure) => emit(MedicineError(failure.message)),
      (medicines) => emit(MedicinesLoaded(medicines)),
    );
  }

  Future<void> _onSearchMedicinesByName(SearchMedicinesByNameEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final result = await searchMedicinesByName(token: event.token, name: event.name);
    result.fold(
      (failure) => emit(MedicineError(failure.message)),
      (medicines) => emit(SearchMedicinesLoaded(medicines)),
    );
  }

  Future<void> _onGetMedicinesByCategory(GetMedicinesByCategoryEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final result = await getMedicinesByCategory(token: event.token, category: event.category);
    result.fold(
      (failure) => emit(MedicineError(failure.message)),
      (medicines) => emit(MedicinesLoaded(medicines)),
    );
  }

  Future<void> _onGetMedicineById(GetMedicineByIdEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final result = await getMedicineById(medicineId: event.medicineId, token: event.token);
    
    result.fold(
      (failure) => emit(MedicineError(failure.message)),
      (medicine) => emit(SingleMedicineLoaded(medicine)),
    );
  }

  Future<void> _onWriteMedicineReview(WriteMedicineReviewEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final result = await writeMedicineReview(WriteMedicineReviewParams(
      medicineId: event.medicineId,
      message: event.message,
      token: event.token,
    ));
    result.fold(
      (failure) => emit(MedicineError(failure.message)),
      (_) => emit(MedicineReviewWritten()),
    );
  }

  Future<void> _onGetMedicineReviews(GetMedicineReviewsEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final result = await getMedicineReviews(medicineId: event.medicineId, token: event.token);
    result.fold(
      (failure) => emit(MedicineError(failure.message)),
      (reviews) => emit(MedicineReviewsLoaded(reviews)),
    );
  }

  Future<void> _onGetUserRecommendations(GetUserRecommendationsEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final result = await getUserRecommendations(token: event.token);
    result.fold(
      (failure) => emit(MedicineError(failure.message)),
      (medicines) =>{
        print('Recommendations loaded: ${medicines.length} items'),
       emit(RecommendationsLoaded(medicines)),
      },
    );
  }
}