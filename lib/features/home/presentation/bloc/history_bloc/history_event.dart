part of 'history_bloc.dart';

abstract class HistoryEvent {}

class LoadHistory extends HistoryEvent {}

class SearchHistory extends HistoryEvent {
  final String query;
  SearchHistory(this.query);
}

class DeleteHistoryTrip extends HistoryEvent {
  final String docId;
  DeleteHistoryTrip(this.docId);
}

class _UpdateHistoryData extends HistoryEvent {
  final List<QueryDocumentSnapshot> docs;
  _UpdateHistoryData(this.docs);
}