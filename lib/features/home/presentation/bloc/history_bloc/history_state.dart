part of 'history_bloc.dart';

abstract class HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<QueryDocumentSnapshot> trips;
  final List<QueryDocumentSnapshot> allTrips;
  final String searchQuery;

  HistoryLoaded({
    required this.trips,
    required this.allTrips,
    this.searchQuery = ""
  });
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}