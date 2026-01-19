part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}

class AuthVerificationRequired extends AuthEvent {
  final String email;
  AuthVerificationRequired(this.email);

  @override
  List<Object?> get props => [email];
}

class CheckEmailVerification extends AuthEvent {}

class ResendVerificationEmail extends AuthEvent {}
