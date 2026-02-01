part of 'user_name_cubit.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}
class UserProfileLoading extends UserProfileState {}
class UserProfileLoaded extends UserProfileState {
  final String displayName;
  UserProfileLoaded(this.displayName);
}
class UserProfileError extends UserProfileState {
  final String message;
  UserProfileError(this.message);
}