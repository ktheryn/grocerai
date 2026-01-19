import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerai/features/auth/data/services/secure_storage.dart';
import 'package:grocerai/locator.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {

    final secureStorage = getIt<SecureStorageService>();
    final firebaseAuth = getIt<FirebaseAuth>();

    on<AppStarted>((event, emit) async {
      emit(AuthInitial());
      await Future.delayed(const Duration(seconds: 2));
      try {
        final user = firebaseAuth.currentUser;

        if (user != null) {
          await user.reload();

          final token = await secureStorage.getToken();

          if (user.emailVerified && token != null) {
            emit(AuthAuthenticated());
          } else {
            emit(AuthVerificationState(user.email ?? ""));
          }
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        await firebaseAuth.signOut();
        await secureStorage.deleteToken();
        emit(AuthUnauthenticated());
      }
    });

    on<AuthLoggedIn>((event, emit) {
      emit(AuthAuthenticated());
    });

    on<AuthLoggedOut>((event, emit) async {
      await secureStorage.deleteToken();
      emit(AuthUnauthenticated());
    });

    on<AuthVerificationRequired>((event, emit) {
      emit(AuthVerificationState(event.email));
    });

    on<CheckEmailVerification>((event, emit) async {
      emit(AuthLoading());

      final user = firebaseAuth.currentUser;
      await user?.reload();
      if (user != null && user.emailVerified) {
        final token = await user.getIdToken();
        await secureStorage.saveToken(token!);
        emit(AuthAuthenticated());
      } else {
        emit(AuthVerificationState(user?.email ?? ''));
      }
    });


    on<ResendVerificationEmail>((event, emit) async {
      final user = firebaseAuth.currentUser;
      await user?.sendEmailVerification();
      emit(AuthVerificationState(user?.email ?? ''));
    });
  }
}
