import 'package:bloc/bloc.dart';
import 'package:medlink_mobileapp/core/error/failure.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';
import 'package:medlink_mobileapp/features/Pharmacy/domain/usecase/profile_usecase.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfile;
  final UpdateProfileUseCase updateProfile;

  ProfileBloc(this.getProfile, this.updateProfile) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await getProfile(event.token);
    print("bloc");
    print(result);
    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(ProfileError(failure.message, errors: failure.errors));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    print("updatebloc");
    print(event.profile);
    final result = await updateProfile(event.token, event.profile);
    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(ProfileError(failure.message, errors: failure.errors));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (_) => emit(ProfileUpdated()),
    );
  }
}
