enum AuthError {
  invalidEmail,
  emailAlreadyInUse,
  weakPassword,
  unhandledError,
  unknownError,
  noInternetConnection,
  invalidCredential,
  emailNotVerified,
}

extension AuthErrorMessage on AuthError {
  String get message {
    switch (this) {
      case AuthError.invalidEmail:
        return 'The email address is badly formatted.';
      case AuthError.emailAlreadyInUse:
        return 'This email is already registered.';
      case AuthError.weakPassword:
        return 'The password is too weak.';
      case AuthError.unhandledError:
        return 'We cannot process you account right now. Please check email and password';
      case AuthError.unknownError:
        return 'Something went wrong please try again';
      case AuthError.noInternetConnection:
        return 'Please check your internet connection';
      case AuthError.invalidCredential:
        return 'Invalid email or password';
      case AuthError.emailNotVerified:
        return 'Please verify your email before logging in';
    }
  }
}