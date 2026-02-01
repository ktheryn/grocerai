part of 'archive_bloc.dart';

abstract class ArchiveState {}
class ArchiveInitial extends ArchiveState {}
class ArchiveLoading extends ArchiveState {}
class ArchiveSuccess extends ArchiveState {}
class ArchiveError extends ArchiveState {
  final String message;
  ArchiveError(this.message);
}