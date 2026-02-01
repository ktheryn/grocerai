part of 'ai_generated_bloc.dart';

sealed class AiGeneratedEvent extends Equatable {
  const AiGeneratedEvent();
}

class GenerateFromRecipe extends AiGeneratedEvent {
  final String recipeName;
  const GenerateFromRecipe(this.recipeName);

  @override
  List<Object> get props => [recipeName];
}


class GenerateSmartRestockSuggestions extends AiGeneratedEvent {
  const GenerateSmartRestockSuggestions();
  @override
  List<Object?> get props => [];
}