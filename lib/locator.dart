import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerai/features/auth/data/services/secure_storage.dart';


final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
  );
}