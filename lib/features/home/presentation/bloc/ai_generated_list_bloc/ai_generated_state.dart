part of 'ai_generated_bloc.dart';

sealed class AiGeneratedState extends Equatable {
  final AiOperation operation;
  const AiGeneratedState(this.operation);

  @override
  List<Object?> get props => [operation];
}

final class AiGeneratedInitial extends AiGeneratedState {
  const AiGeneratedInitial(super.operation);
}

final class AiGeneratedLoading extends AiGeneratedState {
  const AiGeneratedLoading(super.operation);
}

final class AiGeneratedLoaded extends AiGeneratedState {
  final List<GroceryItem> items;

  const AiGeneratedLoaded({
    required this.items,
    required AiOperation operation,
  }) : super(operation);

  @override
  List<Object?> get props => [items, operation];
}

final class AiGeneratedError extends AiGeneratedState {
  final String errorMessage;

  const AiGeneratedError({
    required this.errorMessage,
    required AiOperation operation,
  }) : super(operation);

  @override
  List<Object?> get props => [errorMessage, operation];
}