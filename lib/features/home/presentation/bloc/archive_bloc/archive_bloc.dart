import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocerai/locator.dart';
import 'package:grocerai/features/home/data/archive_repository.dart';
import 'package:grocerai/features/home/domain/grocery.dart';

part 'archive_event.dart';
part 'archive_state.dart';

class ArchiveBloc extends Bloc<ArchiveEvent, ArchiveState> {
  final ArchiveRepository _repository = getIt<ArchiveRepository>();

  ArchiveBloc() : super(ArchiveInitial()) {
    on<ArchiveListRequested>(_onArchiveRequested);
  }

  Future<void> _onArchiveRequested(
      ArchiveListRequested event,
      Emitter<ArchiveState> emit
      ) async {
    if (event.items.isEmpty) {
      emit(ArchiveError("Your list is empty."));
      return;
    }

    emit(ArchiveLoading());
    try {
      await _repository.archiveTrip(
        items: event.items,
        totalSpent: event.total,
      );
      emit(ArchiveSuccess());
    } catch (e) {
      emit(ArchiveError(e.toString()));
    }
  }
}