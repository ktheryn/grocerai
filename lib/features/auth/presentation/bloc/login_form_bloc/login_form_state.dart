part of 'login_form_bloc.dart';

enum AuthMode { login, register }

class LoginFormState extends Equatable {
  final Email email;
  final Password password;
  final FormzSubmissionStatus status;
  final bool showPassword;
  final AuthMode authMode;
  final String authError;
  final String infoMessage;

  const LoginFormState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.showPassword = false,
    this.authMode = AuthMode.login,
    this.authError = '',
    this.infoMessage = '',
  });

  @override
  List<Object> get props => [email, password, status, showPassword, authMode, authError];

  LoginFormState copyWith({
    Email? email,
    Password? password,
    FormzSubmissionStatus? status,
    bool? showPassword,
    AuthMode? authMode,
    String? authError,
    String? infoMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      showPassword: showPassword ?? this.showPassword,
      authMode: authMode ?? this.authMode,
      authError: authError ?? this.authError,
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }
}
