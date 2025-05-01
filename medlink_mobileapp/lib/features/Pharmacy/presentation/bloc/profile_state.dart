import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;
  ProfileLoaded(this.profile);
}

class ProfileUpdated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  final Map<String, dynamic>? errors;
  ProfileError(this.message, {this.errors});
}
