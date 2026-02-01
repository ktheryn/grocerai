import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formz/formz.dart';
import 'package:grocerai/core/internet_connection_checker.dart';
import 'package:grocerai/features/auth/data/services/secure_storage.dart';
import 'package:grocerai/features/auth/domain/auth_error_messages.dart';
import 'package:grocerai/features/auth/domain/email.dart';
import 'package:grocerai/features/auth/domain/password.dart';
import 'package:grocerai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:grocerai/locator.dart';

part 'login_form_event.dart';
part 'login_form_state.dart';

class LoginFormBloc
    extends Bloc<LoginFormEvent, LoginFormState> {
  final AuthBloc authBloc;
  LoginFormBloc(this.authBloc) : super(const LoginFormState()) {

    final secureStorage = getIt<SecureStorageService>();
    final firebaseAuth = getIt<FirebaseAuth>();

    on<SignInEmailChanged>((event, emit) async {
      final email = Email.dirty(event.email);
      emit(state.copyWith(
        email: email,
      ));
    });

    on<SignInPasswordChanged>((event, emit) async {
      final password = Password.dirty(event.password);
      emit(state.copyWith(
        password: password,
      ));
    });

    on<SignIn>((event, emit) async {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      final email = Email.dirty(event.email);
      final password = Password.dirty(event.password);

      final isConnectedToInternet =
          await InternetConnectionChecker().hasConnection();

      if (!isConnectedToInternet) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            authError: AuthError.noInternetConnection.message));
        return;
      }

      if (email.value.isEmpty || password.value.isEmpty) {
        return;
      }

      final isValid = Formz.validate([email, password]);
      if (!isValid) {
        emit(state.copyWith(
            email: email,
            password: password,
            authError: AuthError.invalidCredential.message,
            status:FormzSubmissionStatus.failure));
        return;
      }

      try {
        UserCredential user = await firebaseAuth
            .signInWithEmailAndPassword(
                email: email.value, password: password.value);

        if (user.user != null) {
          final token = await user.user!.getIdToken();
          await secureStorage.saveToken(token!);
          authBloc.add(AuthLoggedIn());
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        }
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            authError: AuthError.invalidCredential.message));
      } catch (e) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            authError: AuthError.unknownError.message));
      }
    });

    on<SignUp>((event, emit) async {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      final email = Email.dirty(event.email);
      final password = Password.dirty(event.password);

      final isConnectedToInternet =
          await InternetConnectionChecker().hasConnection();

      if (!isConnectedToInternet) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            authError: AuthError.noInternetConnection.message));
        return;
      }

      try {
        UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
                email: email.value, password: password.value);

        if (user.user != null) {
          final String uid = user.user!.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'fullName': event.userName,
            'email': email.value,
            'createdAt': FieldValue.serverTimestamp(),
          });

          await user.user!.sendEmailVerification();

          authBloc.add(AuthVerificationRequired(email.value));

          emit(state.copyWith(
              status: FormzSubmissionStatus.success,
              infoMessage: "Verification email sent to ${email.value}. Please verify before logging in."
          ));
        }
      } on FirebaseAuthException catch (e) {
          emit(state.copyWith(
              status: FormzSubmissionStatus.failure,
              authError: e.message));
      } catch (e) {
        emit(state.copyWith(
            status: FormzSubmissionStatus.failure,
            authError: AuthError.unknownError.message));
      }
    });

    on<SignOut>((event, emit) async {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        await firebaseAuth.signOut();
        secureStorage.deleteToken();
        if (firebaseAuth.currentUser == null) {
          authBloc.add(AuthLoggedOut());
          emit(state.copyWith(status: FormzSubmissionStatus.success));
        }
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    });

    on<PasswordShow>((event, emit) async {
      emit(state.copyWith(showPassword: !state.showPassword));
    });

    on<SwitchAuthMode>((event, emit) async {
      emit(state.copyWith(
          authMode: event.authMode, email: const Email.pure(), // Reset email
          password: const Password.pure(), status: FormzSubmissionStatus.initial));
    });
  }
}
