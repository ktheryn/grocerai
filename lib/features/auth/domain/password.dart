import 'package:formz/formz.dart';

enum PasswordValidationError { invalid}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure([super.value = '']) : super.pure();
  const Password.dirty([super.value = '']) : super.dirty();

  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  PasswordValidationError? validator(String value) {
    if (!_passwordRegex.hasMatch(value)) {
      return PasswordValidationError.invalid;
    }
    return null;
  }
}

extension PasswordValidationErrorText on PasswordValidationError {
  String text() {
    switch (this) {
      case PasswordValidationError.invalid:
        return 'Invalid Password';
    }
  }
}