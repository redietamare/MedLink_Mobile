import 'package:medlink_mobileapp/features/Pharmacy/domain/entity/profile.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {
  final String token;

  LoadProfile(this.token);
}

class UpdateProfileEvent extends ProfileEvent {
  final String token;
  final Profile profile;

  UpdateProfileEvent(this.token, this.profile);
}
