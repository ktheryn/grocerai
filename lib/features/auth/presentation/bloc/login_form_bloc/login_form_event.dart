part of 'login_form_bloc.dart';

abstract class LoginFormEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStartEvent extends LoginFormEvent {
  @override
  List<Object> get props => [];
}

class SignInEmailChanged extends LoginFormEvent {
  final String email;

  SignInEmailChanged({required this.email});
  @override
  List<Object> get props => [email];
}

class SignInPasswordChanged extends LoginFormEvent {
  final String password;

  SignInPasswordChanged({required this.password});
  @override
  List<Object> get props => [password];
}

class SignIn extends LoginFormEvent {
  final String email;
  final String password;

  SignIn({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class SignUp extends LoginFormEvent {
  final String email;
  final String password;
  final String userName;

  SignUp({required this.email, required this.password, required this.userName});
  @override
  List<Object> get props => [email, password];
}

class SignOut extends LoginFormEvent {
  @override
  List<Object> get props => [];
}

class PasswordShow extends LoginFormEvent {
  @override
  List<Object> get props => [];
}

class SwitchAuthMode extends LoginFormEvent {
  final AuthMode authMode;

  SwitchAuthMode({required this.authMode});
  @override
  List<Object> get props => [authMode];
}

class PasswordReset extends LoginFormEvent {
  final String email;

  PasswordReset({required this.email});
  @override
  List<Object> get props => [email];
}