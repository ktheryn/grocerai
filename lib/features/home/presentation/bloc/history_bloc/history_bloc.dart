import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerai/features/home/data/history_grocery_repository.dart';
import 'package:grocerai/locator.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final _repository = getIt<HistoryGroceryRepository>();
  StreamSubscription? _subscription;

  HistoryBloc() : super(HistoryLoading()) {
    on<LoadHistory>(_onLoadHistory);
    on<_UpdateHistoryData>(_onUpdateData);
    on<SearchHistory>(_onSearch);
    on<DeleteHistoryTrip>(_onDelete);
  }

  void _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) {
    _subscription?.cancel();
    _subscription = _repository.getHistoryStream().listen(
          (docs) => add(_UpdateHistoryData(docs)),
      onError: (e) => emit(HistoryError(e.toString())),
    );
  }

  void _onUpdateData(_UpdateHistoryData event, Emitter<HistoryState> emit) {
    final currentQuery = state is HistoryLoaded ? (state as HistoryLoaded).searchQuery : "";
    _filterAndEmit(emit, event.docs, currentQuery);
  }

  void _onSearch(SearchHistory event, Emitter<HistoryState> emit) {
    if (state is HistoryLoaded) {
      _filterAndEmit(emit, (state as HistoryLoaded).allTrips, event.query);
    }
  }

  void _filterAndEmit(Emitter<HistoryState> emit, List<QueryDocumentSnapshot> allDocs, String query) {
    final filtered = allDocs.where((doc) {
      final items = (doc.data() as Map<String, dynamic>)['items'] as List? ?? [];
      return items.any((i) => i['item'].toString().toLowerCase().contains(query.toLowerCase()));
    }).toList();

    emit(HistoryLoaded(trips: filtered, allTrips: allDocs, searchQuery: query));
  }

  Future<void> _onDelete(DeleteHistoryTrip event, Emitter<HistoryState> emit) async {
    try {
      await _repository.deleteHistoryTrip(event.docId);
    } catch (e) {
      emit(HistoryError("Failed to delete trip: $e"));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}