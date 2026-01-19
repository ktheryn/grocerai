part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthVerificationState extends AuthState {
  final String email;
  AuthVerificationState(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthLoading extends AuthState {}

