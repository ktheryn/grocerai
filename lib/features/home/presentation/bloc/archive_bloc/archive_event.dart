part of 'archive_bloc.dart';

abstract class ArchiveEvent {}
class ArchiveListRequested extends ArchiveEvent {
  final List<GroceryItem> items;
  final double total;
  ArchiveListRequested(this.items, this.total);
}