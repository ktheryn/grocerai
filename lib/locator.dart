import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocerai/features/auth/data/services/secure_storage.dart';
import 'package:grocerai/features/home/data/ai_grocery_repository.dart';
import 'package:grocerai/features/home/data/archive_repository.dart';
import 'package:grocerai/features/home/data/grocery_repository.dart';
import 'package:grocerai/features/home/data/user_profile_repository.dart';

import 'features/home/data/history_grocery_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  getIt.registerLazySingleton<GroceryRepository>(() => GroceryRepository());
  getIt.registerLazySingleton<GenerativeModel>(
    () => FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    ),
  );
  getIt.registerLazySingleton<AIGeneratedGroceryRepository>(
    () => AIGeneratedGroceryRepository(),
  );

  getIt.registerLazySingleton<HistoryGroceryRepository>(
    () => HistoryGroceryRepository(),
  );
  getIt.registerLazySingleton<ArchiveRepository>(() => ArchiveRepository());
  getIt.registerLazySingleton(() => UserRepository());
}
