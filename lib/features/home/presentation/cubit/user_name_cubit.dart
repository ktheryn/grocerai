import 'package:bloc/bloc.dart';
import 'package:grocerai/features/home/data/user_profile_repository.dart';
import 'package:grocerai/locator.dart';

part 'user_name_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository _repository = getIt<UserRepository>();

  UserProfileCubit() : super(UserProfileInitial());

  Future<void> loadUserProfile() async {
    emit(UserProfileLoading());
    try {
      final name = await _repository.getUserName();
      emit(UserProfileLoaded(name));
    } catch (e) {
      emit(UserProfileLoaded("Shopper")); // Fallback to default on error
    }
  }
}