
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/usecase/pharmacy_usecase.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/pharmacy_event.dart';
import 'package:medlink_mobileapp/features/Pharmacy/presentation/bloc/pharmacy_state.dart';

class PharmacyBloc extends Bloc<PharmacyEvent, PharmacyState> {
  final GetAllPharmacies getAllPharmacies;
  final GetPharmacyById getPharmacyById;
  final GetPharmacyReviews getPharmacyReviews;
  final WritePharmacyReview writePharmacyReview;
  final GetPharmacyProducts getPharmacyProducts;

  PharmacyBloc({
    required this.getAllPharmacies,
    required this.getPharmacyById,
    required this.getPharmacyReviews,
    required this.writePharmacyReview,
    required this.getPharmacyProducts,
  }) : super(PharmacyInitial()) {
    on<GetAllPharmaciesEvent>(_onGetAllPharmacies);
    on<GetPharmacyByIdEvent>(_onGetPharmacyById);
    on<GetPharmacyReviewsEvent>(_onGetPharmacyReviews);
    on<WritePharmacyReviewEvent>(_onWritePharmacyReview);
    on<GetPharmacyProductsEvent>(_onGetPharmacyProducts);
  }

  Future<void> _onGetAllPharmacies(GetAllPharmaciesEvent event, Emitter<PharmacyState> emit) async {
    emit(PharmacyLoading());
    final result = await getAllPharmacies(token: event.token);
    result.fold(
      (failure) => emit(PharmacyError(_mapFailureToMessage(failure))),
      (pharmacies) => emit(PharmaciesLoaded(pharmacies)),
    );
  }

  Future<void> _onGetPharmacyById(GetPharmacyByIdEvent event, Emitter<PharmacyState> emit) async {
    emit(PharmacyLoading());
    final result = await getPharmacyById(pharmacyId: event.pharmacyId, token: event.token);
    result.fold(
      (failure) => emit(PharmacyError(_mapFailureToMessage(failure))),
      (pharmacy) => emit(SinglePharmacyLoaded(pharmacy)),
    );
  }

  Future<void> _onGetPharmacyReviews(GetPharmacyReviewsEvent event, Emitter<PharmacyState> emit) async {
    emit(PharmacyLoading());
    final result = await getPharmacyReviews(pharmacyId: event.pharmacyId, token: event.token);
    result.fold(
      (failure) => emit(PharmacyError(_mapFailureToMessage(failure))),
      (reviews) => emit(PharmacyReviewsLoaded(reviews)),
    );
  }

  Future<void> _onWritePharmacyReview(WritePharmacyReviewEvent event, Emitter<PharmacyState> emit) async {
    emit(PharmacyLoading());
    final result = await writePharmacyReview(event.params);
    result.fold(
      (failure) => emit(PharmacyError(_mapFailureToMessage(failure))),
      (_) => emit(PharmacyReviewWritten()),
    );
  }

  Future<void> _onGetPharmacyProducts(GetPharmacyProductsEvent event, Emitter<PharmacyState> emit) async {
    emit(PharmacyLoading());
    final result = await getPharmacyProducts(pharmacyId: event.pharmacyId, token: event.token);
    result.fold(
      (failure) => emit(PharmacyError(_mapFailureToMessage(failure))),
      (medicines) => emit(PharmacyProductsLoaded(medicines)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Unauthorized: Please log in again';
    }
    return failure is ServerFailure ? failure.message : 'Unexpected error';
  }
}
